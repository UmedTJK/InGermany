Views → VMs → Repos → DataService → NetworkService/CacheService

# Dependency Graph — InGermany (v2.3)

```
Views
  ↓
ViewModels
  ↓
Repositories
  ↓
DataService (actor — target state)
  ↓
NetworkService   CacheService (actor)
```

---

## 🔎 Current Reality (Post Stabilization 2026-02-22)

### ⚠ Deviations Identified

- `NetworkService` now supports retry/backoff + cancellation semantics (✅).
- `NetworkService` now has strict in-flight deduplication for network loads (✅).
- `NetworkService` is instrumented via DI-based metrics + DEBUG overlay (✅).
- Remaining risk: verify ViewModels are not globally `@MainActor` when doing async I/O (audit during F5/F6).
- Remaining risk: ensure no silent `catch {}` blocks remain in refresh helpers across the codebase.

---

## 🎯 Target Concurrency Model

### Rules

1. Data layer must be actor-isolated.
2. No `Task.detached` in app layer.
3. No async work inside initializers.
4. ViewModels update UI via `MainActor.run` only where necessary.
5. All background refresh must use structured concurrency.
6. Errors must never be silently swallowed.
7. Networking must support strict in-flight deduplication per resource.
8. Observability hooks must be DI-based and DEBUG-safe (no overhead in Release).

---

## 📦 Layer Responsibilities

### Views
- Pure rendering.
- No business logic.
- No direct service access (avoid Service Locator).

### ViewModels
- Orchestrate async flows.
- Handle state.
- Do not be globally `@MainActor`.

### Repositories
- Thin abstraction over DataService.
- No UI state.
- No `@MainActor`.

### DataService
- Single source of truth.
- Actor-isolated.
- Responsible for cache + network coordination.
- Supports cancellation + retry.

### NetworkService
- Pure networking + offline-first glue (file cache/bundle fallback).
- Configurable timeout and injectable `URLSession` for tests.
- Retry/backoff with cancellation semantics.
- Strict in-flight deduplication for network loads.
- DI-based metrics instrumentation (DEBUG overlay supported).

### CacheService
- Actor-based TTL memory cache.

---

## 🧭 Stabilization Phase Status

- DI structure: ✅ Stable
- Concurrency discipline: ✅ Stabilized (TSAN clean under stress)
- Error handling discipline: ✅ Hardened (no silent swallow in critical paths)
- Layer separation: ✅ Good
- Lifecycle binding: ✅ Improved (DEBUG observability available)

---

This document reflects the current dependency state after F4 stabilization and the target direction for F5/F6 improvements.
