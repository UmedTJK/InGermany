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
  - FavoritesManager (exposed via protocol FavoritesManagingProtocol)
  - RatingManager
  - ReadingStatsManager (exposed via ReadingStatsManagingProtocol; concrete kept private in AppContainer)
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
6. Concrete managers may be injected into SwiftUI only via explicit UI-only accessors in AppContainer (no direct concrete leakage).

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
  - Injected via protocol into ViewModels
  - Concrete instance is private in AppContainer
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
- Encapsulated ReadingStatsManager behind protocol and UI-only accessor
- Temporarily disabled reading statistics in Settings to prevent main-thread UI freeze

---

## How to add a new dependency (recipe)
1. Define protocol in `Protocols/`
2. Implement concrete type in `Services/` or `Managers/`
3. Add instance creation in `AppContainer`
4. Inject protocol into ViewModel initializer
5. Update tests to compose the dependency explicitly

# InGermany — Architecture Specification (v2.0)

---

## 1. Architectural Principles

This project follows a strict Dependency Injection architecture with a single composition root.

Core principles:

1. No hidden global state (no singletons in production code).
2. All dependencies are explicit via initializers.
3. Clear separation of Presentation, Domain, and Data layers.
4. Unidirectional dependency flow.
5. Testability by construction.

AppContainer is the only composition root.

---

## 2. Tech Stack

- SwiftUI
- MVVM
- async/await
- Protocol-oriented design
- Dependency Injection via AppContainer

---

## 3. Layered Architecture

### 3.1 Presentation Layer

Contains:
- SwiftUI Views
- ViewModels

Rules:

- Views never instantiate services, repositories, or managers.
- Views may only receive:
  - ViewModels
  - Lightweight value objects
  - Factory closures
- ViewModels receive all dependencies via initializer injection.
- ViewModels depend only on protocols, never concrete implementations.
- Presentation layer must not import UIKit unless strictly required for UI bridging.

Strictly forbidden:

- Direct usage of DataService, NetworkService, CacheService in Views.
- Creating managers inside Views.
- Accessing global state.

---

### 3.2 Domain Layer

Contains:
- Protocol definitions
- Pure business logic
- Domain abstractions (e.g. Repositories protocols, Managing protocols)

Rules:

- No references to concrete implementations.
- No references to SwiftUI.
- No references to UIKit.
- No global state access.

The Domain layer defines contracts only.

---

### 3.3 Data Layer

Contains:
- Repository implementations
- Services (DataService)
- Infrastructure (NetworkService, CacheService)
- State managers (FavoritesManager, RatingManager, etc.)

Rules:

- Concrete types are created only inside AppContainer.
- DataService depends explicitly on NetworkService and CacheService.
- Repositories depend on DataService via protocol.
- No reverse dependency to Presentation layer.

---

## 4. Dependency Flow

Allowed direction:

Presentation → Domain (Protocols) → Data (Concrete)

Disallowed:

Data → Presentation
Domain → Data (concrete)
View → Service (concrete)

Dependency graph must remain acyclic.

---

## 5. Composition Root (AppContainer)

AppContainer is responsible for:

- Instantiating all concrete services
- Wiring repositories
- Wiring managers
- Providing factory methods for ViewModels

Rules:

- No other file may create core services.
- No other file may construct repository graphs.
- No static shared access.

If a dependency is needed in a ViewModel, it must be injected via AppContainer.

---

## 6. Dependency Injection Policy

### 6.1 Constructor Injection

All non-trivial dependencies must be injected via initializer.

Example:

init(repository: ArticlesRepositoryProtocol,
     favoritesManager: FavoritesManagingProtocol)

Forbidden:

- static let shared
- .shared usage
- Accessing global singletons

---

### 6.2 EnvironmentObject Policy

EnvironmentObject is allowed only for UI-scoped state that is truly global across the UI tree.

Allowed examples:
- AppContainer
- LocalizationManager
- TextSizeManager

Restrictions:
- ViewModels must not depend on EnvironmentObject directly.
- EnvironmentObject is considered a UI convenience, not a service locator.
- Core business logic must not rely on EnvironmentObject.

---

## 7. Threading Policy

- Managers mutating UI-related state must be @MainActor.
- Network operations must execute off the main thread.
- DataService must not depend on SwiftUI or MainActor.
- ViewModels that update UI state must ensure MainActor safety.

No blocking operations on the main thread.

---

## 8. Performance Guidelines

ViewModels:
- Avoid heavy computed properties recalculated during View body updates.
- Avoid synchronous large data transformations.
- Prefer memoization where appropriate.
- Statistics and heavy aggregations must not be computed directly inside SwiftUI body via computed properties.

Views:
- Avoid expensive work inside body.
- Avoid nested GeometryReaders unless necessary.

Services:
- Avoid repeated JSON decoding of identical data.
- Cache responsibly.

---

## 9. Responsibilities

### 9.1 DataService

- Single entry point for loading structured app data.
- Orchestrates cache and network.

### 9.2 Repositories

- Provide domain-ready data to ViewModels.
- Hide infrastructure details.

### 9.3 Managers

- Own mutable application state.
- Encapsulate specific responsibility (favorites, ratings, stats, etc.).

Single Responsibility Principle must be enforced.

---

## 10. Testing Strategy

- No global state in tests.
- No .shared usage in tests.
- Each test composes dependencies explicitly.
- Prefer small mock implementations over partial real services.

ViewModel tests must not require SwiftUI.

---

## 11. Anti-Patterns (Strictly Forbidden)

- Instantiating services in Views
- Accessing .shared in production code
- Service locator patterns
- Circular dependencies
- UIKit calls inside Domain/Data layer

---

## 12. Migration History

The project was migrated from singleton-heavy architecture to full DI:

- Removed all *.shared usage
- Introduced protocol-based contracts
- Centralized wiring in AppContainer
- Stabilized test suite under DI
- Encapsulated ReadingStatsManager behind protocol and UI-only accessor
- Temporarily disabled reading statistics in Settings to prevent main-thread UI freeze

---

## 13. Adding a New Dependency (Recipe)

1. Define protocol in Protocols/.
2. Implement concrete type in appropriate layer.
3. Register instance in AppContainer.
4. Inject protocol into ViewModel initializer.
5. Update tests to compose dependency explicitly.

No shortcuts.

---

End of specification.

# InGermany — Architecture Specification (v2.2)

📅 Updated: 2026-02-21  
🏷 Status: Concurrency Stabilization Phase  

---

# 1. Architectural Principles

This project follows a strict Dependency Injection architecture with a single composition root.

Core principles:

1. No hidden global state (no singletons in production code).
2. All dependencies are explicit via initializers.
3. Clear separation of Presentation, Domain, and Data layers.
4. Unidirectional dependency flow.
5. Testability by construction.
6. Structured concurrency only (no uncontrolled background tasks).

AppContainer is the only composition root.

---

# 2. Tech Stack

- SwiftUI
- MVVM
- async/await (structured concurrency only)
- Protocol-oriented design
- Dependency Injection via AppContainer

---

# 3. Layered Architecture

## 3.1 Presentation Layer

Contains:
- SwiftUI Views
- ViewModels

Rules:

- Views never instantiate services, repositories, or managers.
- Views may receive:
  - ViewModels
  - Lightweight value objects
  - Factory closures
- ViewModels receive all dependencies via initializer injection.
- ViewModels depend only on protocols.
- ViewModels must not be globally marked `@MainActor`.
- UI state mutations must be wrapped in `MainActor.run` when necessary.
- No async work inside ViewModel initializers.
- No `Task.detached` in Presentation layer.

Strictly forbidden:

- Direct usage of DataService, NetworkService, CacheService in Views.
- Creating managers inside Views.
- Service locator patterns via EnvironmentObject.
- Silent error swallowing.

---

## 3.2 Domain Layer

Contains:
- Protocol definitions
- Pure business logic
- Domain abstractions

Rules:

- No references to concrete implementations.
- No references to SwiftUI.
- No references to UIKit.
- No global state access.
- No concurrency side-effects.

The Domain layer defines contracts only.

---

## 3.3 Data Layer

Contains:
- Repository implementations
- DataService
- Infrastructure (NetworkService, CacheService)
- State managers (FavoritesManager, RatingManager, ReadingStatsManager, etc.)

Rules:

- Concrete types are created only inside AppContainer.
- DataService must be actor-isolated.
- No `Task.detached` in Data layer.
- All background refresh must use structured concurrency.
- No silent `catch {}` blocks.
- Repositories must not be `@MainActor`.
- No reverse dependency to Presentation layer.

---

# 4. Dependency Flow

Allowed direction:

Presentation → Domain (Protocols) → Data (Concrete)

Disallowed:

Data → Presentation  
Domain → Concrete Data  
View → Concrete Service  

Dependency graph must remain acyclic.

---

# 5. Composition Root (AppContainer)

AppContainer is responsible for:

- Instantiating all concrete services
- Wiring repositories
- Wiring managers
- Providing factory methods for ViewModels

Rules:

- No other file may create core services.
- No other file may construct repository graphs.
- No static shared access.
- No UI logic inside AppContainer.
- AppContainer must not perform heavy async work on initialization.

---

# 6. Dependency Injection Policy

## 6.1 Constructor Injection

All non-trivial dependencies must be injected via initializer.

Forbidden:

- static let shared
- .shared usage
- Accessing global singletons
- Implicit dependency lookup

---

## 6.2 EnvironmentObject Policy

EnvironmentObject is allowed only for true UI-global state.

Allowed examples:
- LocalizationManager
- TextSizeManager

Restrictions:
- ViewModels must not depend on EnvironmentObject.
- EnvironmentObject must not act as service locator.
- AppContainer exposure via EnvironmentObject is discouraged and must not be used to bypass DI.

---

# 7. Concurrency & Threading Policy (Hardened)

## 7.1 Structured Concurrency Only

Allowed:
- async/await
- Task (child tasks only)
- withTaskGroup

Forbidden:
- Task.detached
- DispatchQueue for async business logic
- Async work inside initializers
- Blocking I/O on MainActor

---

## 7.2 Actor Isolation

- DataService must be actor-isolated.
- CacheService is actor-based.
- Managers mutating UI state may use `@MainActor`.
- Repositories must not be globally `@MainActor`.

---

## 7.3 Error Handling Discipline

- No empty catch blocks.
- Errors must be:
  - Propagated
  - Logged
  - Converted to domain-safe results
- Retry and timeout policies must be implemented in NetworkService.

---

# 8. Performance Guidelines

ViewModels:
- Avoid heavy computed properties recalculated during View updates.
- Avoid synchronous large transformations.
- Memoize expensive derived data.
- Do not perform grouping/sorting inside SwiftUI body.

Views:
- No heavy work in body.
- No nested expensive layout structures.

Services:
- Avoid repeated JSON decoding of identical data.
- Cache responsibly.
- Avoid main-thread blocking.

---

# 9. Responsibilities

## 9.1 DataService
- Single source of truth.
- Orchestrates cache + network.
- Must support cancellation.
- Must not swallow errors silently.

## 9.2 Repositories
- Provide domain-ready data.
- Thin abstraction over DataService.
- No UI state.
- No MainActor binding.

## 9.3 Managers
- Own specific mutable application state.
- Must not perform heavy I/O on main thread.
- No async work in initializer.

Single Responsibility Principle must be enforced.

---

# 10. Testing Strategy

- No global state in tests.
- No .shared usage.
- Each test composes dependencies explicitly.
- Prefer mock protocols.
- Async flows must be testable deterministically.
- No implicit background work inside initializers.

---

# 11. Anti-Patterns (Strictly Forbidden)

- Instantiating services in Views
- Accessing .shared in production code
- Service locator patterns
- Circular dependencies
- UIKit in Domain/Data
- Task.detached
- Silent catch blocks

---

# 12. Stabilization Phase (v0.2.4 → v0.3 Target)

Current status: F4 Concurrency Stabilization Completed (2026‑02‑22)

Completed milestones:

1. All Task.detached usage removed.
2. DataService fully actor-isolated.
3. Strict in-flight deduplication implemented in NetworkService.
4. Cancellation-aware retry policy implemented and verified.
5. Structured concurrency enforced across layers.
6. DataService refresh deduplication hardened.
7. Thread Sanitizer (TSAN) run clean under stress.
8. Concurrency test suite deterministic and green.

The stabilization phase is complete. The architecture is now concurrency-safe and production-ready.

Future phases will focus on performance optimization, observability, and feature expansion rather than corrective stabilization.

---

# 13. Migration History

The project was migrated from singleton-heavy architecture to full DI:

- Removed all *.shared usage
- Introduced protocol-based contracts
- Centralized wiring in AppContainer
- Stabilized test suite under DI
- Encapsulated ReadingStatsManager behind protocol
- Entered Concurrency Stabilization Phase (2026-02)

---

# 14. Adding a New Dependency (Recipe)

1. Define protocol in Protocols/.
2. Implement concrete type in appropriate layer.
3. Register instance in AppContainer.
4. Inject protocol into ViewModel initializer.
5. Update tests to compose dependency explicitly.
6. Ensure structured concurrency compliance.

No shortcuts.

---

End of Architecture Specification v2.1
