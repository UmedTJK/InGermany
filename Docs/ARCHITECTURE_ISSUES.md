# 🚧 Architecture Issues — InGermany  
_Актуальность: v1.14.0 (2025-10-09)_

Этот документ фиксирует текущие архитектурные проблемы проекта **InGermany**, а также отмечает уже исправленные недочёты.  
Цель — обеспечить прозрачность, видеть прогресс и понимать приоритеты следующих задач.

---

## 🚨 Актуальные архитектурные проблемы

### 1. Использование `AppContainer.shared` во ViewModel
- В `ArticleDetailViewModel` по-прежнему используется глобальный вызов `AppContainer.shared`.
- Это нарушает строгие принципы Dependency Injection (DI).

**Решение:** передавать зависимости через конструктор или фабрики `AppContainer`, а не обращаться к синглтону внутри ViewModel.

---

### 2. UI-логика во ViewModel
- В `ArticleDetailViewModel` есть метод `currentFont`, который жёстко задаёт `.system(size: 16 * textSizeManager.customScale)`.
- Это относится к уровню UI, а не бизнес-логики.

**Решение:** перенести выбор шрифта в `TextSizeManager` или выделенный UI-хелпер.

---

### 3. Шаринг реализован слишком жёстко
- Метод `shareContent` во ViewModel возвращает длинную строку с заголовком, текстом и временем чтения.
- При добавлении новых форматов (PDF, rich text, JSON) придётся переписывать логику.

**Решение:** вынести формирование контента в отдельный сервис (`ShareService`), а во ViewModel оставить только вызов.

---

### 4. Недостаток unit-тестов
- Есть тесты для `HomeViewModel`, но они покрывают только базовые сценарии.
- Не протестированы:
  - `ReadingStatsManager` (сессии, прогресс, статистика),
  - `ArticleDetailViewModel`,
  - `SettingsViewModel`.

**Решение:** расширить покрытие unit-тестами для ключевых менеджеров и ViewModel.

---

### 5. Ограниченная валидация моделей
- В `Article.swift` и `Category.swift` возможны force-unwrap ситуации при работе с JSON.
- Нет fallback-значений, если локализованный заголовок или текст отсутствует.

**Решение:** добавить безопасные геттеры и дефолтные fallback-значения.

---

## ✅ Уже исправлено (v1.14.0)

- **DI:** ViewModel теперь получают зависимости через конструктор, а не напрямую из синглтонов.  
- **Менеджеры:** удалён устаревший `ReadingHistoryManager`, заменён на новый `ReadingStatsManager` с протоколом `ReadingStatsManaging`.  
- **Прогресс чтения:** реализованы `updateProgress`, `startSession`, `endSession`, расчёт статистики.  
- **EnvironmentObject:** исправлено использование в `ContentView` и `AppContainer`.  
- **SOLID:** улучшена структура `HomeViewModel`, устранено дублирование логики, соблюдены принципы разделения ответственности.  

---

## 📊 Чеклист прогресса

- [ ] Убрать `AppContainer.shared` из `ArticleDetailViewModel`  
- [ ] Вынести UI-логику (`currentFont`) в `TextSizeManager` или UI-хелпер  
- [ ] Вынести `shareContent` в отдельный сервис  
- [ ] Добавить unit-тесты для `ReadingStatsManager`, `ArticleDetailViewModel`, `SettingsViewModel`  
- [ ] Усилить валидацию моделей (`Article`, `Category`)  
- [x] Перевести ViewModel на конструкторный DI  
- [x] Удалить `ReadingHistoryManager` и заменить на `ReadingStatsManager`  
- [x] Исправить `EnvironmentObject` в `ContentView` и `AppContainer`  
- [x] Оптимизировать `HomeViewModel` под SOLID  

---
