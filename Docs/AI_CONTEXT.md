# AI_CONTEXT.md — InGermany (iOS)
**Last update:** 2026-02-21  
**Repository scope:** iOS app only (SwiftUI). macOS Editor is in a separate repository and is NOT a dependency here.



## 1) Project Overview

**InGermany** — iOS приложение-справочник для жизни в Германии: статьи/категории/локации/PDF + персонализация (избранное, история, прогресс чтения, статистика) + мультиязычность.

**UI:** SwiftUI  
**Arch style (current):** MVVM + Repository + Actor-based data layer + DI container (AppContainer) + explicit bootstrap  
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
  - `CategoriesRepositoryImpl` — DI repository; publishes categories on MainActor, loads via injected DataService
- **Services**
  - `DataService` (actor) — core offline-first orchestrator (cache, load, refresh, streams)
  - `NetworkService` (class; DI-owned) — bundle/cache/network loader + file cache; retry + cancellation-aware backoff; refresh dedup per file
  - `CacheService` (actor singleton) — TTL memory cache
  - `DefaultsStore` — UserDefaults Codable helpers (sync + async variants; JSON encode/decode off-main)
- **Managers**
  - Managers are DI-owned instances created by AppContainer; persistence bootstrapped explicitly (no async side-effects in init).
  - `SettingsManager` — ObservableObject wrapper over `@AppStorage`
- **Formatters / UIUtils** — formatting + UI helpers

### 3.2 Real data flow
Typical flow (Articles):
View → ViewModel → ArticlesRepository → DataService(actor) → NetworkService(bundle/file/network) + CacheService → decoded `[Article]`

Categories:
CategoriesRepositoryImpl.bootstrap() → DataService.loadCategories() (injected)

### 3.3 Current DI truth (important)

DI is now the primary composition mechanism.

- `AppContainer` creates repositories, services, managers and ViewModels via factory methods.
- No `.shared` singletons are used in the production graph (Docs may still mention historic usage).
- App lifecycle uses explicit bootstrapping:
  - `AppContainer.bootstrap()` preloads localization and bootstraps persistent managers (reading stats, favorites) asynchronously.
- `SettingsManager` is a single source of truth instance (created in `InGermanyApp.init()` and injected into `AppContainer`).

---

## 4) Concurrency & Threading Model (current reality)

- `DataService` is an **actor**: protects its own caches and streams.
- `CacheService` is an **actor**: protects TTL cache.
- `NetworkService` is a class (not actor). Concurrency is strengthened via: retry + cancellation-aware backoff and in-flight refresh dedup per file.
- Background refresh uses structured Tasks (no Task.detached). DataService and NetworkService both deduplicate in-flight refreshes to avoid request storms.

**Rule:** any new shared mutable state must be in an actor (or otherwise synchronized).

---

## 5) Settings & App State (current reality)

- Theme + language + UI prefs are stored via `SettingsManager`:
  - `@AppStorage("selectedLanguage")`
  - `@AppStorage("isDarkMode")`
  - `@AppStorage("relativeDates")`
  - `@AppStorage("selectedCardStyleIndex")`

InGermanyApp injects a single SettingsManager instance into the environment and uses it as the theme source (preferredColorScheme). The same instance is injected into AppContainer.

**Reading statistics are bootstrapped explicitly and persisted via async DefaultsStore (encode/decode off-main).**

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

### 7.1 Remaining DI hardening
Most of the production graph is DI-owned. Remaining work: reduce service-locator footprint in SwiftUI Environment and continue protocol-first boundaries where valuable for tests.

### 7.2 AppContainer is @MainActor (broad isolation)
AppContainer is currently @MainActor; future cleanup may narrow MainActor isolation to UI-only state to reduce accidental main-thread coupling.

### 7.3 NetworkService is not actor
NetworkService is still not an actor. While dedup + retry improved safety, full actor conversion or synchronized file-cache critical sections may be considered if contention appears.

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
2) Continue protocol-first DI where it increases test value (e.g., NetworkService/SettingsStore), but avoid premature abstraction.
3) Convert NetworkService to actor OR synchronize file-cache critical sections (if needed).
4) Replace `@AppStorage` usage in core UI flow with a protocol-driven SettingsStore (optional)
5) Add integration tests for DI graph + offline-first scenarios

---

## 10) Quick Orientation (where to look)

- DI root: `Core/AppContainer.swift`
- App entry & env: `Core/InGermanyApp.swift`
- Tabs composition: `Core/ContentView.swift`
- Data core: `Services/DataService.swift` (actor)
- Network loader: `Services/NetworkService.swift` (retry + dedup refresh)
- TTL cache: `Services/CacheService.swift` (actor)
- Settings: `Managers/SettingsManager.swift`
- UserDefaults helper: `Services/DefaultsStore.swift` (async variants)
- Repos: `Repositories/*`
