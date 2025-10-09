🚧 Architecture Issues — InGermany

📅 Обновлено: 2025-10-09 • Версия: v1.14.1

Документ фиксирует текущие архитектурные проблемы проекта InGermany, а также отмечает уже решённые.
Цель — видеть прогресс и приоритеты следующих шагов.

🚨 Актуальные архитектурные проблемы
1. Использование AppContainer.shared во ViewModel

После рефакторинга DI в AppContainer и InGermanyApp глобальные вызовы практически убраны.

⚠️ Остался только один случай в ArticleDetailViewModel.

Решение: полностью убрать AppContainer.shared, передавать зависимости через AppContainer или фабрики.

2. UI-логика во ViewModel

В ArticleDetailViewModel остался метод currentFont, который жёстко задаёт .system(size: …).

Часть UI-логики уже вынесена, но проблема полностью не решена.

Решение: перенести выбор шрифта и визуальные правила в TextSizeManager или отдельный UI-хелпер.

3. Шаринг реализован слишком жёстко

shareContent во ViewModel формирует строку вручную.

При расширении (PDF, rich text, JSON) код придётся переписывать.

Решение: вынести формирование контента в сервис (ShareService), оставить во ViewModel только вызов.

4. Недостаток unit-тестов

Есть базовые тесты для HomeViewModel.

Не протестированы:

ReadingStatsManager (сессии, прогресс, статистика),

ArticleDetailViewModel,

SettingsViewModel.

Решение: расширить покрытие тестами для ключевых менеджеров и ViewModel.

5. Ограниченная валидация моделей

В Article.swift и Category.swift возможны ситуации с отсутствующими данными.

Нет fallback-значений для локализации заголовка/контента.

Решение: добавить безопасные геттеры и дефолтные fallback-значения.

✅ Уже исправлено

DI: ViewModel и экраны получают зависимости через AppContainer, убраны прямые .shared.

Менеджеры: ReadingHistoryManager удалён, заменён на ReadingStatsManager + протокол ReadingStatsManaging.

Прогресс чтения: реализованы updateProgress, startSession, endSession, расчёт статистики.

EnvironmentObject: исправлено в ContentView и InGermanyApp.

SOLID: улучшена структура HomeViewModel, устранено дублирование логики.

UI: убран лишний forced cast для ReadingStatsManager в ContentView.

📌 Следующие шаги:

Убрать последний вызов AppContainer.shared (в ArticleDetailViewModel).

Вынести UI-логику (currentFont) в сервис.

Вынести shareContent в отдельный ShareService.

Добавить unit-тесты для ReadingStatsManager и ViewModel.

Добавить fallback-значения в модели Article и Category.
