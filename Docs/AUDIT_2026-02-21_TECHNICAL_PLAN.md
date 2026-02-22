# InGermany — Technical Audit & Fix Plan (2026-02-21)

Scope: Read-only audit of Composition Root + Data layer + Home screen.
Files reviewed:
- Core: InGermanyApp.swift, ContentView.swift, AppContainer.swift, View+AppEnvironment.swift
- Services: DataService.swift, NetworkService.swift, CacheService.swift, DefaultsStore.swift
- Repositories: ArticlesRepositoryImpl.swift, CategoriesRepositoryImpl.swift
- Managers: FavoritesManager.swift, ReadingStatsManager.swift
- Home: HomeView.swift, HomeViewModel.swift

Status: ✅ DI structure is strong, ❗ concurrency discipline requires stabilization.

## 0) Progress Snapshot

Completed items in branch `fix/concurrency-stabilization-2026-02`:
- ✅ A1. Remove `Task.detached` in HomeViewModel
- ✅ A2. Remove `Task.detached` in DataService, add deduplication and cancellation
- ✅ A3. Replace silent catch blocks with logging and error propagation
- ✅ A4. Actor-isolate DataService with proper state isolation and no detached tasks
- ✅ B1. Remove `@MainActor` from CategoriesRepositoryImpl
- ✅ B2. Remove global `@MainActor` from HomeViewModel, keep UI mutations on main
- ✅ C1. NetworkService reliability: added retry, cancellation-aware backoff, and refresh deduplication
- ✅ D1. Memoize `articlesByCategory` to reduce recomputation
- ✅ D2. DefaultsStore operations moved off-main with async wrappers
- Managers moved to explicit bootstrap pattern (no async work in init)
- DataService.loadLocal replaced with structured concurrency
- NetworkService enhanced with retry and cancellation-aware backoff; refresh deduplication implemented
- DataService refresh deduplication and cancellation checks added
- ✅ E1/F1. Single SettingsManager source (App init injected into AppContainer)
- ✅ E2/F2. Environment policy cleanup: remove AppContainer from all UI (factories only)

---

## 1) Issues (Prioritized)

### 🔴 P0 — Critical (stability, races, uncontrolled tasks)

**P0-1 — Uncontrolled `Task.detached` in DataService** ✅ Resolved  
- Location: `DataService.loadCategories`, `DataService.loadLocations` (background refresh pattern)  
- Why: detached tasks do not inherit cancellation/priority and are not lifecycle-bound → races, duplicate refresh, UI updates after screen exit.  
- How to reproduce: trigger loads repeatedly (tab switching, pull-to-refresh), observe multiple refresh executions / inconsistent source.

**P0-2 — Uncontrolled `Task.detached` in HomeViewModel** ✅ Resolved  
- Location: `HomeViewModel.loadData()` (background refresh)  
- Why: same detached problems + VM may become stale/deallocated; updates can still arrive.  
- How to reproduce: open Home → quickly switch away → return; observe jumps or refresh timing anomalies.

**P0-3 — Silent error swallowing (`catch {}`)** ✅ Resolved  
- Location: `DataService.refreshArticlesIfNeeded`, `refreshCategoriesIfNeeded`, `refreshLocationsIfNeeded`  
- Why: destroys observability, breaks retry logic, impossible to test error-path.  
- How to reproduce: go offline, observe missing error state/logs and silent failures.

**P0-4 — MainActor-bound orchestration that performs I/O** ✅ Resolved  
- Location: `HomeViewModel` is `@MainActor` while doing async data loading; `CategoriesRepositoryImpl` is `@MainActor` while calling async loads.  
- Why: increases actor hopping, increases risk of main thread stalls under load, blurs layer boundaries.

**P0-5 — DataService shared mutable state requires actor isolation** ✅ Resolved (actor isolation + dedup + no detached)  
- Location: caches (`articlesCache/categoriesCache/locationsCache`), `lastDataSource`, continuations/yield lists in DataService.  
- Risk: if not actor-isolated → data races; even if isolated, detached refresh breaks discipline.

---

### 🟠 P1 — High Priority (architecture cleanliness, testability, perf)

**P1-1 — Duplicate SettingsManager source** ✅ Resolved  
- Location: SettingsManager created in both `InGermanyApp` and `AppContainer`  
- Risk: state divergence.

**P1-2 — DefaultsStore sync JSON encode/decode** ✅ Resolved  
- Location: `DefaultsStore.load/save`  
- Risk: can block main thread for large payloads.

**P1-3 — ReadingStatsManager performs async work in init** ✅ Resolved  
- Location: `ReadingStatsManager.init() { Task { ... } }`  
- Risk: hidden side effects, flaky tests, unpredictable lifecycle.

**P1-4 — ReadingStatsManager creates LocalizationManager internally** ✅ Resolved  
- Location: `private let localizationManager = LocalizationManager()`  
- Risk: violates DI, multiple localization sources.

**P1-5 — Legacy GCD usage for local JSON load** ✅ Resolved  
- Location: `DataService.loadLocal` uses `DispatchQueue.global + withCheckedContinuation`  
- Risk: not cancellable, harder reasoning and testing.

**P1-6 — Heavy recomputation of derived data** ✅ Resolved  
- Location: `HomeViewModel.articlesByCategory` computed via `Dictionary(grouping:)`  
- Risk: repeated O(n) recomputation on every publish/body update.

**P1-7 — Network reliability policy incomplete** ✅ Resolved  
- Location: NetworkService should enforce timeout + retry/backoff; needs hardening/validation.

---

### 🟡 P2 — Refinements (non-blockers but recommended)

**P2-1 — AppContainer marked `@MainActor` too broadly**  
- Risk: MainActor “leaks” into composition/wiring.

**P2-2 — AppContainer exposed as EnvironmentObject (Service Locator risk)** ✅ Resolved  
- Location: `View+AppEnvironment.swift` and Views using `@EnvironmentObject appContainer`  
- Risk: any view can bypass DI and pull services directly.

**P2-3 — Theme application duplicated**  
- Location: simultaneously using `preferredColorScheme` and `environment(\.colorScheme, ...)`  
- Risk: potential inconsistencies.

---

## 2) Solutions (What to change)

### ✅ Fixes for P0

**Fix P0-1 / P0-2 — Remove all `Task.detached`**  
- Replace with structured concurrency:  
  - `Task { ... }` (inherits cancellation/priority)  
  - or `withTaskGroup` for parallel loads  
  - bind background refresh to ViewModel lifecycle  
- Add deduping: at most 1 refresh per resource at a time.  
- Add cancellation checks: `guard !Task.isCancelled else { return }`.

**Fix P0-3 — Remove silent catch**  
- Replace `catch {}` with:  
  - logging (OSLog/Logger)  
  - error propagation (Result or throws)  
  - predictable fallback behavior (bundle/cache) while still recording errors.

**Fix P0-4 — Remove global `@MainActor` from ViewModels/Repositories that do I/O**  
- ViewModels: do I/O off-main, wrap only UI mutations in `await MainActor.run { ... }`.  
- Repositories: should not be MainActor-bound. If they publish UI state, split into:  
  - repository (pure data, not ObservableObject)  
  - UI wrapper (ObservableObject) if needed.

**Fix P0-5 — Actor-isolate DataService**  
- Convert to `actor DataService`  
- Keep all mutable state inside actor isolation.  
- Ensure refresh flow does not escape actor guarantees.

---

### ✅ Fixes for P1

**Fix P1-1 — One SettingsManager**  
- Choose single source of truth:  
  - created in AppContainer and injected into App, OR  
  - created in App and passed into AppContainer.

**Fix P1-2 — DefaultsStore heavy operations off-main**  
- Introduce async wrappers (load/save using Task background).  
- Consider batching or reducing payload size.

**Fix P1-3 — No async work in init**  
- Replace ReadingStatsManager init Task with explicit `bootstrap()` called from AppContainer/bootstrap or first screen task.

**Fix P1-4 — Inject LocalizationManager**  
- ReadingStatsManager should receive localization service via init (protocol).

**Fix P1-5 — Replace GCD loadLocal**  
- Move local file read & decode into structured concurrency:  
  - background Task + `JSONDecoder` there  
  - cancellation-aware flow.

**Fix P1-6 — Memoize articlesByCategory**  
- Make it stored state updated only when `articles` changes.

**Fix P1-7 — Network reliability**  
- Add:  
  - request/resource timeouts  
  - retry/backoff policy (configurable)  
  - unified error model (NetworkError)

---

### ✅ Fixes for P2

**Fix P2-1 — Remove `@MainActor` from AppContainer**  
- Keep managers that mutate UI state as `@MainActor` (or isolate their own state appropriately).

**Fix P2-2 — Reduce Service Locator footprint**  
- Avoid exposing AppContainer via EnvironmentObject.  
- Keep EnvironmentObject for true UI-global state only (localization/text size/theme).

**Fix P2-3 — Single theme mechanism**  
- Use either `preferredColorScheme` or `environment(\.colorScheme, ...)`, not both.

---

## 3) Work Plan (Order, Files, Verification)

### Phase A — Concurrency Stabilization (P0) ✅ DONE

**A1. Remove `Task.detached` in HomeViewModel**  
- Files: `ViewModels/HomeViewModel.swift`  
- Verify:  
  - leaving Home cancels background refresh  
  - no UI updates from stale tasks

**A2. Remove `Task.detached` in DataService**  
- Files: `Services/DataService.swift`  
- Add dedup & cancellation.  
- Verify:  
  - repeated loads/refresh do not spawn uncontrolled tasks  
  - predictable refresh behavior

**A3. Replace silent catch blocks**  
- Files: `Services/DataService.swift`  
- Verify:  
  - offline triggers logged/observable errors  
  - tests can assert failure paths

**A4. Actor-isolate DataService**  
- Files: `Services/DataService.swift`, usages via protocol  
- Verify:  
  - Thread Sanitizer: 0 races  
  - parallel load calls remain deterministic

---

### Phase B — MainActor boundary cleanup (P0/P1) ✅ DONE

**B1. Remove `@MainActor` from CategoriesRepositoryImpl**  
- Files: `Repositories/CategoriesRepositoryImpl.swift`  
- Verify:  
  - UI still updates correctly  
  - no main-thread warnings

**B2. Remove global `@MainActor` from HomeViewModel**  
- Files: `ViewModels/HomeViewModel.swift`  
- Verify:  
  - only UI mutations on main  
  - I/O stays off-main

---

### Phase C — Reliability (P1) ✅ DONE

**C1. Introduce timeout + retry/backoff in NetworkService**  
- Files: `Services/NetworkService.swift`  
- Verify:  
  - bad network results in bounded attempts and clear failure state  
  - cancellation-aware backoff and refresh deduplication implemented

---

### Phase D — Performance (P1/P2) ✅ DONE

**D1. Memoize `articlesByCategory`**  
- Files: `ViewModels/HomeViewModel.swift`  
- Verify:  
  - less CPU usage on scroll and repeated updates (Instruments)

**D2. DefaultsStore async**  
- Files: `Services/DefaultsStore.swift`, `Managers/ReadingStatsManager.swift`, `Managers/FavoritesManager.swift`  
- Verify:  
  - no UI freeze during save/load of history/favorites

---

### Phase E — DI & Environment cleanup (P1/P2) ✅ DONE

**E1. Single SettingsManager source** ✅ DONE  
- Files: `Core/InGermanyApp.swift`, `Core/AppContainer.swift`  
- Verify:  
  - theme/settings consistent between UI and VMs

**E2. Environment policy** ✅ DONE  
- Files: `Core/View+AppEnvironment.swift`, views relying on container  
- Verify:  
  - grep shows zero `@EnvironmentObject.*AppContainer` in Views/Core/UIUtils  
  - UI composed via factories only; AppContainer stays in composition root

---

### Phase F — Remaining Work (Open) (Next)

**F3. AppContainer MainActor leakage cleanup (Optional / nice-to-have)**  
- Files: `Core/AppContainer.swift`  
- Notes:  
  - remove broad `@MainActor` annotation  
  - keep only UI-mutating managers or state isolated on MainActor

**F4. Tests & reliability hardening (Recommended)**  
- Add unit tests for retry/backoff logic in NetworkService  
- Add tests for async DefaultsStore operations  
- Add tests for DataService refresh deduplication and cancellation  
- Run Thread Sanitizer (TSAN) to confirm zero data races

---

## 4) Definition of Done (Stabilization)

- Zero `Task.detached` in app code  
- Zero `catch {}` without logging/propagation  
- DataService actor-isolated  
- Repositories are not `@MainActor`  
- ViewModels not globally `@MainActor` unless explicitly justified  
- Network timeout + retry implemented and covered by tests  
- Zero @EnvironmentObject AppContainer usages in Views/Core/UIUtils  
- Thread Sanitizer: 0 data races  
- No main-thread stalls during data load/scroll (Instruments)  
- NetworkService retry is cancellation-aware and refresh is deduplicated per file  
- DefaultsStore async is used by managers (ReadingStatsManager, FavoritesManager) with explicit bootstrap

---

End of document.
