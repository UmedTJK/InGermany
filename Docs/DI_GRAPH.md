Views → VMs → Repos → DataService → NetworkService/CacheService

# Dependency Graph — InGermany (v2.1)

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

## 🔎 Current Reality (Post Audit 2026-02)

### ⚠ Deviations Identified

- `CategoriesRepositoryImpl` currently marked `@MainActor` (to be removed).
- `HomeViewModel` globally marked `@MainActor` while performing async I/O (to refactor).
- `DataService` uses `Task.detached` for background refresh (to eliminate).
- Silent `catch {}` blocks exist in refresh helpers (to harden).
- No retry / timeout strategy in `NetworkService` (to introduce).

---

## 🎯 Target Concurrency Model

### Rules

1. Data layer must be actor-isolated.
2. No `Task.detached` in app layer.
3. No async work inside initializers.
4. ViewModels update UI via `MainActor.run` only where necessary.
5. All background refresh must use structured concurrency.
6. Errors must never be silently swallowed.

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
- Pure networking.
- Configurable timeout.
- Retry/backoff support (planned).

### CacheService
- Actor-based TTL memory cache.

---

## 🧭 Stabilization Phase Status

- DI structure: ✅ Stable
- Concurrency discipline: ⚠ In refactor
- Error handling discipline: ⚠ Hardening required
- Layer separation: ✅ Good
- Lifecycle binding: ⚠ Improving

---

This document reflects the audited dependency state and the target refactored architecture direction.
