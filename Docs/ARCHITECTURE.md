# InGermany — Architecture

## Tech stack
- SwiftUI
- MVVM
- async/await
- Dependency Injection via composition root (AppContainer)

## High-level goals
- No singletons in production code (no hidden global state)
- Explicit dependencies through initializers (testable by construction)
- Presentation depends on protocols, not concrete implementations
- AppContainer is the only composition root

---

## Module boundaries (conceptual)

### Presentation layer
**Contains:**
- SwiftUI Views (Screens/Components/Sections)
- ViewModels

**Rules:**
- Views never create services/repos/managers directly.
- ViewModels receive all dependencies via initializer.
- Views may use EnvironmentObject only for UI-scoped state that is truly global for UI tree
  (e.g. LocalizationManager, TextSizeManager) — injected from AppContainer/InGermanyApp.

### Domain layer
**Contains:**
- Protocols (e.g. FavoritesManagingProtocol, ReadingStatsManagingProtocol, Repositories protocols)
- Pure business logic (where applicable)

**Rules:**
- No references to concrete services.
- No direct access to shared/global singletons.

### Data layer
**Contains:**
- Repositories implementations
- Services: DataService
- Infrastructure: NetworkService, CacheService
- Managers: FavoritesManager, RatingManager, ReadingStatsManager, TextSizeManager, LocalizationManager

**Rules:**
- Concrete implementations are created only in AppContainer (composition root).
- DataService depends on NetworkService + CacheService (explicit DI).

---

## Dependency graph (current)

### Composition Root
`AppContainer` builds and owns the dependency graph:

AppContainer
- Repositories
  - ArticlesRepositoryImpl (depends on DataServiceProtocol)
  - CategoriesRepositoryImpl (depends on DataServiceProtocol)
- Services
  - DataService (depends on NetworkService + CacheService)
- Managers (UI/state)
  - FavoritesManager
  - RatingManager
  - ReadingStatsManager
  - TextSizeManager
  - LocalizationManager

### Flow direction
Presentation → Protocol → Concrete

- Views → ViewModels
- ViewModels → Protocols
- AppContainer provides concrete implementations

No reverse dependencies from Data/Managers into Presentation.

---

## DI strategy

### Rules
1. No `.shared` in production code.
2. All service/manager/repository dependencies are injected through initializers.
3. AppContainer is the only place where concrete instances are created.
4. Views do not instantiate dependencies (except small value objects).
5. Tests compose dependencies explicitly (no shared global state).

### Environment injection
In `InGermanyApp` we inject:
- `appContainer` as EnvironmentObject
- UI-scoped managers (if needed) as EnvironmentObject
  (LocalizationManager, TextSizeManager, etc.)

---

## Protocols and responsibilities

### Services
- **NetworkService**
  - Offline-first JSON loading
  - Bundle → File Cache → Network (async refresh)
- **CacheService**
  - Storage for cached resources (used by DataService)

### DataService
- Single entry point for loading app data (articles/categories/etc.)
- Depends on NetworkService + CacheService

### Repositories
- **ArticlesRepositoryImpl**
  - Provides articles data to ViewModels
- **CategoriesRepositoryImpl**
  - Provides categories data to ViewModels

### Managers (state / UI-related)
- **FavoritesManager** (FavoritesManagingProtocol)
  - Tracks favorites, provides favorite filtering, toggle, etc.
- **RatingManager**
  - Stores and retrieves user ratings
- **ReadingStatsManager** (ReadingStatsManagingProtocol)
  - Tracks read status, history, stats
- **TextSizeManager**
  - Tracks user preferred text size
- **LocalizationManager**
  - Translation lookup & preload

---

## Testing strategy
- Tests do not use global singletons.
- Every test composes dependencies explicitly:
  - `NetworkService()` + `CacheService()` + `DataService(...)`
  - managers instantiated per test when needed
- Prefer small helper factories inside tests for ViewModel construction.

---

## Anti-patterns (explicitly запрещено)
- Instantiating managers/services in Views
- Accessing `.shared` in production code
- Protocols referencing concrete types or global state
- Repositories pulling dependencies via singletons

---

## Migration notes
This project was migrated from singleton-heavy access (`*.shared`) to explicit DI:
- Favorites DI cleanup (UI + ViewModels decoupled from concrete manager)
- Rating/TextSize/ReadingStats/Localization moved to DI
- CacheService + NetworkService moved to DI
- DataService and repositories composed via AppContainer

---

## How to add a new dependency (recipe)
1. Define protocol in `Protocols/`
2. Implement concrete type in `Services/` or `Managers/`
3. Add instance creation in `AppContainer`
4. Inject protocol into ViewModel initializer
5. Update tests to compose the dependency explicitly
