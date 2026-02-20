# AI_CONTEXT.md — InGermany (iOS)
**Last update:** 2026-02-20  
**Repository scope:** iOS app only (SwiftUI). macOS Editor is in a separate repository and is NOT a dependency here.



## 1) Project Overview

**InGermany** — iOS приложение-справочник для жизни в Германии: статьи/категории/локации/PDF + персонализация (избранное, история, прогресс чтения, статистика) + мультиязычность.

**UI:** SwiftUI  
**Arch style (current):** MVVM + Repository + Actor-based data layer + Hybrid DI (DI facade over several singletons)  
**Offline-first:** Bundle → in-memory/disk cache → network refresh

---

## 2) Source of Truth

### 2.1 Domain Models (truth)
Source of truth for domain models is **App-layer Models**:
- `Models/Article.swift` (Codable, Hashable, чистая модель)
- `Models/Category.swift`
- `Models/Location.swift`

**Rule:** When changing domain fields or JSON schema, update these models FIRST.

### 2.2 Data truth / persistence
Primary data inputs:
- `Resources/*.json` (articles, categories, locations)
Runtime caching:
- Memory: `DataService` internal caches
- Disk (memory TTL cache): `CacheService` actor
- File cache for network JSON: `NetworkService` file cache

---

## 3) High-Level Architecture (current reality)

### 3.1 Layers
- **Core**
  - `Core/InGermanyApp.swift` — app entry + environment injection
  - `Core/ContentView.swift` — TabView composition (lazy per tab)
  - `Core/AppContainer.swift` — DI container *facade*, VM factories
- **Views** (SwiftUI screens, sections, components)
- **ViewModels** (MVVM logic)
- **Protocols** (contracts for repos/managers/services)
- **Repositories**
  - `ArticlesRepositoryImpl` — thin wrapper over `DataService`
  - `CategoriesRepositoryImpl` — singleton repository that bootstraps categories from `DataService`
- **Services**
  - `DataService` (actor) — core offline-first orchestrator (cache, load, refresh, streams)
  - `NetworkService` (singleton class) — bundle/cache/network loader + file cache
  - `CacheService` (actor singleton) — TTL memory cache
  - `DefaultsStore` — UserDefaults Codable helpers
- **Managers**
  - Favorites/Rating/TextSize/Localization/ReadingStats/etc. (many are singletons)
  - `SettingsManager` — ObservableObject wrapper over `@AppStorage`
- **Formatters / UIUtils** — formatting + UI helpers

### 3.2 Real data flow
Typical flow (Articles):
View → ViewModel → ArticlesRepository → DataService(actor) → NetworkService(bundle/file/network) + CacheService → decoded `[Article]`

Categories:
CategoriesRepositoryImpl.shared.bootstrap() → DataService.shared.loadCategories()

### 3.3 Current DI truth (important)
DI exists, but is NOT pure.

`AppContainer` creates view models and provides dependencies, **however** many deps are still singletons:
- `DataService.shared`
- `CategoriesRepositoryImpl.shared`
- `FavoritesManager.shared`, `RatingManager.shared`, `TextSizeManager.shared`, `LocalizationManager.shared`, `ReadingStatsManager.shared`
- `DateFormattingService.shared`, `TextAnalysisService.shared` (in container fields)

**Definition:** Current DI = *factory + service locator facade* over several `.shared`.

---

## 4) Concurrency & Threading Model (current reality)

- `DataService` is an **actor**: protects its own caches and streams.
- `CacheService` is an **actor**: protects TTL cache.
- `NetworkService` is a **class singleton** (not actor): concurrency safety is weaker; it uses its own URLSession + file cache.
- Some code uses `Task.detached` for background refreshes. This is intentional for non-blocking refresh.

**Rule:** any new shared mutable state must be in an actor (or otherwise synchronized).

---

## 5) Settings & App State (current reality)

- Theme + language + UI prefs are stored via `SettingsManager`:
  - `@AppStorage("selectedLanguage")`
  - `@AppStorage("isDarkMode")`
  - `@AppStorage("relativeDates")`
  - `@AppStorage("selectedCardStyleIndex")`

`InGermanyApp` injects `SettingsManager` into environment and uses it as the **single theme source** (preferredColorScheme).

**Note:** This is UI-coupled state; not protocolized yet.

---

## 6) Packages / SharedCore (status)

This repo includes SwiftPM packages:
- `SharedCore` (Package)
- `Packages/ArticleKit`
- `Packages/SharedKit`

**Current runtime status:** They exist in the repo, but they are **not** the core architecture path described above (main app domain uses `Models/*`).

**Rule:** Do not assume packages are used unless Xcode target imports them. Treat them as legacy / experimental until proven otherwise.

---

## 7) Known Architectural Debt (short, high-signal)

### 7.1 Hybrid DI + Singletons
Many dependencies are still `.shared`. This reduces testability and violates pure DIP.

### 7.2 CategoriesRepositoryImpl is singleton + ObservableObject
It maintains published state + byId cache internally and pulls from `DataService.shared`.

### 7.3 NetworkService is not actor
Potential race/consistency risks under concurrent usage; file cache writes happen without explicit synchronization.

### 7.4 SettingsManager uses @AppStorage directly
Harder to test deterministically; not injectable via protocol in a strict way.

---

## 8) “Don’t break these” rules (for humans & AI agents)

### 8.1 Domain rules
- **Models are the truth.** Do not duplicate Article/Category/Location in another module without a migration plan.
- JSON schema changes require updating Models + decoding/encoding logic.

### 8.2 Data layer rules
- Keep offline-first: Bundle/Cache must keep working even if network fails.
- Never make UI depend directly on NetworkService or Bundle reads. UI talks to ViewModels only.

### 8.3 DI rules (current)
- When adding new ViewModel: create it through `AppContainer` factory.
- Prefer constructor injection (even if underlying deps are singletons today).
- Do NOT introduce new `.shared` singletons unless there is a strong reason.

### 8.4 Concurrency rules
- Shared mutable caches → actor.
- Avoid doing heavy I/O on main thread.
- If you add background refresh, ensure it does not block initial UI rendering.

---

## 9) Roadmap to “Architectural Ideal” (future, not current)

Goal: protocol-first DI (no `.shared` in production graph), testable services, clear module boundaries.

Minimal steps (order matters):
1) Introduce protocols for DataService/NetworkService/CacheService (+ mocks)
2) Remove `.shared` usage from repositories (inject protocols)
3) Convert `NetworkService` to actor OR fully synchronize critical sections
4) Replace `@AppStorage` usage in core UI flow with a protocol-driven SettingsStore (optional)
5) Add integration tests for DI graph + offline-first scenarios

---

## 10) Quick Orientation (where to look)

- DI root: `Core/AppContainer.swift`
- App entry & env: `Core/InGermanyApp.swift`
- Tabs composition: `Core/ContentView.swift`
- Data core: `Services/DataService.swift` (actor)
- Network loader: `Services/NetworkService.swift`
- TTL cache: `Services/CacheService.swift` (actor)
- Settings: `Managers/SettingsManager.swift`
- UserDefaults helper: `Services/DefaultsStore.swift`
- Repos: `Repositories/*`
