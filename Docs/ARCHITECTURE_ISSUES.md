🚧 Architecture Issues — InGermany

📅 Обновлено: 2025-10-10 • Версия: v1.14.1+  
✅ ВСЕ ОСНОВНЫЕ АРХИТЕКТУРНЫЕ ПРОБЛЕМЫ РЕШЕНЫ!

## 🎉 АРХИТЕКТУРНЫЕ УСПЕХИ

### ✅ Полностью исправлено:

1. **Устранение AppContainer.shared в ViewModel**
   - ArticleDetailViewModel получает все зависимости через инициализатор
   - Никаких прямых вызовов AppContainer.shared в кодовой базе ViewModel

2. **Вынос UI-логики из ViewModel**  
   - Метод `currentFont` удален из ArticleDetailViewModel
   - Вся логика шрифтов перенесена в TextSizeManager (реализует FontProviding)

3. **Рефакторинг шаринга в отдельный сервис**
   - Создан ShareService с инъекцией зависимостей
   - ArticleDetailViewModel делегирует всю логику шаринга сервису
   - Поддержка протокола ShareServiceProtocol для тестирования

4. **Полное тестовое покрытие**
   - 21 компонент с тестами, 300+ unit-тестов
   - Все критические компоненты покрыты

5. **Валидация моделей с fallback-значениями**
   - Article и Category имеют безопасные геттеры с многоуровневым fallback
   - "No title"/"No content" как последний резерв

6. **✅ ПОЛНОЦЕННЫЙ OFFILINE-FIRST РЕЖИМ И КЭШИРОВАНИЕ**
   - **Трехуровневый кэш**: Memory → File Cache → Bundle Resources
   - **TTL поддержка**: Автоочистка кэша через 15 минут
   - **Умное обновление**: Фоновая синхронизация при появлении сети
   - **Селективное управление**: Очистка отдельных типов данных
   - **Fallback стратегия**: Bundle → File Cache → Network

7. **Инкапсуляция ReadingStatsManager через DI**
   - Concrete ReadingStatsManager скрыт внутри AppContainer
   - ViewModels получают зависимость только через ReadingStatsManagingProtocol
   - Для SwiftUI используется явный UI-only accessor

## 🔄 СЛЕДУЮЩИЕ ШАГИ ДЛЯ СОВЕРШЕНСТВА

### 🎯 Приоритет 1 (Оптимизация):
- **Кэширование изображений** - добавить TTL для картинок
- **Оптимизация размера кэша** - автоматическая очистка старых данных

### 🎯 Приоритет 2 (Расширение):
- **Push-уведомления** для новых статей
- **Фоновая синхронизация** по расписанию

## 📊 ТЕКУЩЕЕ СОСТОЯНИЕ АРХИТЕКТУРЫ

- **DI**: ✅ Полностью реализован через AppContainer
- **SOLID**: ✅ Соответствует принципам  
- **Тестируемость**: ✅ Высокая (протоколы + DI)
- **MainActor**: ✅ Корректная изоляция
- **Swift 6**: ✅ Готовность к миграции
- **Offline-First**: ✅ Полная реализация
- **Кэширование**: ✅ Многоуровневое с TTL

---

**СТАТУС: АРХИТЕКТУРА СТАБИЛЬНА И СООТВЕТСТВУЕТ ЛУЧШИМ ПРАКТИКАМ ПРОМЫШЛЕННОЙ РАЗРАБОТКИ** 🏆

### 🚀 ОСОБЫЕ ДОСТИЖЕНИЯ:

**Offline-First система:**
- 📦 Memory Cache (15 мин TTL) → Быстрый доступ
- 📦 Bundle Resources → Гарантированная доступность  
- 📂 File Cache → Постоянное хранение
- 🌐 Network → Фоновое обновление

**Управление кэшем:**
- ⏰ Автоматическая инвалидация по TTL
- 🗑️ Селективная очистка по типам данных
- 🔄 Фоновая синхронизация
- 📊 Отслеживание источников данных

🚧 Architecture Status — InGermany

📅 Updated: 2026-02-21  
🏷 Milestone: v0.2.3-di-localization-clean  
📘 Architecture Spec: v2.0 (DI-based, Composition Root enforced)

---

## 🎯 CURRENT ARCHITECTURAL STATE

The project has successfully migrated from a singleton-heavy structure to a strict Dependency Injection architecture.

### ✅ Major Achievements

1. **Full Removal of Production Singletons**
   - No `.shared` usage in production code
   - All dependencies injected via initializers
   - AppContainer is the single composition root

2. **Strict Layer Separation**
   - Presentation → Domain → Data (unidirectional)
   - No reverse dependencies
   - Domain layer defines contracts only

3. **DI-Stabilized Test Suite**
   - No global state in tests
   - Explicit dependency composition
   - ViewModels fully testable without SwiftUI runtime

4. **Localization Decoupled from UI Storage**
   - LocalizationManager no longer tightly bound to AppStorage
   - Fully injectable

5. **Offline-First Data Strategy**
   - Memory cache
   - File cache
   - Bundle fallback
   - Network sync
   - TTL-based invalidation

6. **Encapsulated ReadingStatsManager**
   - No concrete leakage outside AppContainer
   - Protocol-only injection in ViewModels
   - UI-only accessor for EnvironmentObject

---

## ⚖️ KNOWN CONSTRAINTS (NOT DEFECTS, BUT DESIGN DECISIONS)

1. **EnvironmentObject Usage**
   - Still used for UI-scoped global state (AppContainer, LocalizationManager)
   - Acceptable under Architecture v2.0 policy
   - Must not leak into Domain logic

2. **UIKit Bridge (if present in ShareService)**
   - UI-layer only
   - Must not propagate into Domain/Data

3. **Settings Persistence via AppStorage**
   - UI-coupled but controlled
   - Acceptable for current scope
   - Future improvement: storage abstraction layer

4. **Reading Statistics Temporarily Disabled in Settings**
   - Heavy computed properties caused UI freeze
   - Statistics removed from Settings UI
   - Planned refactor: snapshot-based async statistics model (v0.3)

---

## 📊 ARCHITECTURE HEALTH METRICS

- DI Compliance: ✅ High
- Layer Integrity: ✅ Strong
- Test Isolation: ✅ Clean
- Global State: ❌ None in production
- Threading Discipline: ✅ MainActor isolated where required
- Circular Dependencies: ❌ None detected

---

## 🔄 NEXT ARCHITECTURAL EVOLUTION (v0.3 Candidate)

1. Introduce lightweight Domain module separation
2. Replace UIKit bridge with injectable presentation adapter
3. Optional: Extract Settings storage abstraction
4. Performance audit (computed properties + scroll-heavy views)

5. Reintroduce Reading Statistics using snapshot-based async aggregation (no heavy logic in SwiftUI body)

---

## 🏁 CONCLUSION

The architecture is stable, DI-compliant, and production-ready.

It follows:
- Explicit dependency wiring
- Clear layering
- Test-first composition
- Offline-first resilience

Further improvements are evolutionary, not corrective.

---

End of status document.

🚧 Architecture Issues — InGermany

📅 Updated: 2026-02-21  
🏷 Milestone: v0.2.4-concurrency-audit  
📘 Architecture Spec: v2.1 (DI-based, Concurrency Stabilization Phase)

---

# ⚠️ ARCHITECTURE STATUS — UNDER STABILIZATION

The project remains DI-based and structurally clean, however a recent deep technical audit (2026-02) identified critical concurrency and lifecycle issues that must be addressed before declaring the system fully production-stable.

This document supersedes previous “architecture fully stable” statements.

---

# 🚨 CRITICAL CONCURRENCY & LIFECYCLE ISSUES (Audit 2026-02)

## 🔴 P0 — Must Be Fixed Immediately

### 1. Uncontrolled `Task.detached` Usage
Locations:
- DataService background refresh
- HomeViewModel background refresh

Risks:
- No cancellation propagation
- No lifecycle binding
- Possible race conditions
- UI updates after ViewModel deallocation
- Priority not inherited

Action:
- Replace with structured concurrency (`Task {}` or task groups)
- Bind to ViewModel lifecycle

---

### 2. Silent Error Swallowing (`catch {}`)
Found in DataService refresh helpers.

Risks:
- Lost diagnostics
- Impossible retry logic
- Undetectable data failures
- Impossible to test failure paths

Action:
- Replace with explicit error propagation or structured logging.

---

### 3. Repository Bound to `@MainActor` While Performing Async I/O
`CategoriesRepositoryImpl` marked `@MainActor`.

Risks:
- Excess actor hopping
- UI-bound data layer
- Performance instability under load

Action:
- Remove `@MainActor`
- Confine MainActor usage to UI state mutation only.

---

### 4. ViewModel Globally Marked `@MainActor` While Performing I/O
`HomeViewModel` is `@MainActor` but performs async data loading.

Risks:
- Unnecessary main-thread hops
- Reduced concurrency flexibility
- Harder to scale

Action:
- Remove global `@MainActor`
- Wrap only UI updates in `MainActor.run`.

---

## 🟠 P1 — High Priority Structural Improvements

### 5. Async Work in Initializer (ReadingStatsManager)
Implicit background Task in `init`.

Risks:
- Hard to test
- Hidden side effects
- Lifecycle unpredictability

Action:
- Introduce explicit `bootstrap()`.

---

### 6. GCD Usage in DataService (`DispatchQueue.global`)
Legacy concurrency pattern.

Risks:
- Not cancellable
- Not structured
- Harder reasoning

Action:
- Replace with structured concurrency primitives.

---

### 7. No Retry / Timeout Strategy in Network Layer
Current network implementation lacks:
- Retry policy
- Backoff strategy
- Explicit timeout configuration

Action:
- Introduce configurable retry/backoff mechanism.

---

### 8. DefaultsStore Synchronous Heavy JSON Work
Large data writes may block main thread.

Action:
- Consider background persistence or batching.

---

## 🟡 P2 — Architectural Refinements

- Service Locator exposure via EnvironmentObject(AppContainer)
- Heavy computed grouping in HomeViewModel
- Missing cancellation checks in async flows
- Hard-coded TTL (15 min) without configuration layer

---

# 📊 UPDATED ARCHITECTURE HEALTH METRICS

- DI Compliance: ✅ High
- Layer Integrity: ✅ Strong
- Test Isolation: ✅ Clean
- Global State: ❌ None in production
- Threading Discipline: ⚠️ Under Refactor
- Structured Concurrency: ⚠️ Partial
- Error Handling Discipline: ⚠️ Needs Hardening
- Circular Dependencies: ❌ None detected

---

# 🧭 CURRENT PHASE: CONCURRENCY STABILIZATION

The next milestone focuses on:

1. Removing all `Task.detached`
2. Making DataService actor-isolated
3. Enforcing structured concurrency
4. Eliminating silent error swallowing
5. Decoupling repositories from MainActor
6. Introducing retry & timeout policies

This is a corrective phase, not a feature phase.

---

# 🏁 CONCLUSION

The architecture is structurally sound (DI, layering, testability), but not yet concurrency-hardened.

The system is entering a stabilization phase focused on:

- Lifecycle correctness
- Deterministic async behavior
- Structured concurrency compliance
- Production-grade reliability

After completion of the stabilization phase (v0.3 target), the architecture can again be considered production-robust.

---

End of status document.
