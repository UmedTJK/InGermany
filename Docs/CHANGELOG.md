# 📖 CHANGELOG

Все заметные изменения в этом проекте документируются здесь.
Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.0.0/).

---


## [Unreleased]
### Added
- _Next: Observability / performance roadmap_

### Changed
- _Next: tighten refresh scheduling + metrics_

### Fixed
- _Next: address any TSAN regressions immediately_


## [v0.3.0-f4-stabilization] – 2026-02-22

### Stabilization (F4)
- Strict in-flight request deduplication implemented in `NetworkService` (shared tasks with waiter-aware cancellation)
- Retry policy hardened: cancellation-aware exponential backoff; `URLError(.cancelled)` treated as structured cancellation
- Refresh scheduling deduped per file to prevent request storms under parallel load

### Tests
- Added/updated unit tests for `NetworkService`:
  - network success decoding
  - retry on 5xx then success
  - invalid JSON decode failure
  - cancellation stops retries deterministically
  - strict parallel-load dedupe (20+ parallel calls → 1 network request)
- Added/updated unit tests for `DataService`:
  - offline-first cache behavior
  - background refresh deduplication (parallel calls → 1 refresh)
  - update behavior gated by `.network` data source
- Persistence tests stabilized for reading history/stats

### Tooling
- Added `.xctestplan` and enabled Thread Sanitizer (TSAN) diagnostics for test runs
- TSAN verified clean under stress runs

### Notes
- F4 stabilization milestone merged to `main` and pushed

---


## [v0.2.3-di-localization-clean] – 2026-02-21

### Architecture & DI
- DI migration completed across app + SharedKit: removed singleton usage and enforced constructor injection
- Localization decoupled: `LocalizationManager` is pure DI (no `AppStorage`, no `.shared`)
- View layer updated to use DI-based `LocalizationManager` + `AppContainer` wiring

### Tests
- Stabilized ViewModel + localization tests after DI migration

### Docs
- Updated `Docs/next_steps.md` with post-migration notes and follow-ups

---

## [v0.2-di-refactor] – 2026-02-21

### Architecture & DI
- Major DI refactor: removed singletons across app code and tests
- Introduced protocol-based DI for services and managers (Favorites, Rating, Cache, Network, ReadingStats, etc.)
- `AppContainer` hardened as composition root: explicit dependency graph and constructor injection
- Formatter/services now require explicit DI (no shared defaults)

### Changed
- Refactored settings architecture: introduced `SettingsManager` as single source of truth
- Bound app color scheme to `SettingsManager`
- Cleaned up `ContentView` dependencies
- Updated environment wiring via AppContainer/AppEnvironment helpers

### Tests
- Test suite updated to be DI-pure (no `.shared` usage)



## [v1.17.0] – 2025-10-23

### Added
- Поддержка мульти-просмотра устройств в ArticleEditorView (iPhone SE, 14, 15, 16, 17 Pro Max, iPad Mini)
- Новый компонент `DeviceFrameView` адаптирован под разные размеры устройств
- По умолчанию выбран **iPhone 17 Pro Max** для предпросмотра

### Changed
- Панель предпросмотра (Preview Toolbar) разделена на 4 секции: масштаб, выбор устройства/ширины, тема, action-кнопки
- Переключение темы (Light/Dark/Auto) теперь влияет **только на экран iPhone**

### Fixed
- Внешний интерфейс macOS-приложения остаётся в системной теме при переключении темы превью

---

## [v1.16.1-20251022] – 2025-10-22

### Added
- Подтверждена работа iOS build на iPhone 17 Pro Max simulator 🎉

### Changed
- Удалены CMS-специфичные зависимости из `SettingsView`
- Унифицированы project references для iOS/macOS таргетов

### Verified
- ✅ iOS build & launch в Simulator
- ✅ macOS CMS JSON export продолжает работать

---

## [v1.16.0] – 2025-10-22

### Added
- macOS таргет (InGermanyCMS) успешно собирается и запускается
- JSON export функциональность с `NSSavePanel` и алертами

### Fixed
- Удалены дублирующиеся `Localizable.xcstrings` и `Package.swift` references вызывающие конфликты сборки
- Заменён отсутствующий `ArticleBlockType` на унифицированный `BlockType`
- Исправлены условные импорты для AppKit / Combine (macOS-only)

### Notes
🎉 Первая успешная сборка macOS. JSON статьи теперь могут экспортироваться напрямую из CMS.

---

## [v1.15.2-20251015] – 2025-10-15

### Added
- PDF Library UI улучшен:
  - Добавлены превью (thumbnails) для PDF-документов
  - Поддержка shimmer-эффекта для fallback-иконок
  - Каскадные анимации появления карточек при первом открытии экрана
  - Плавные анимации появления при скролле
- Новый утилитарный класс `PDFThumbnailGenerator` в `UIUtils/`

### Changed
- Обновлён `PDFLibraryView` для более современного и «живого» интерфейса
- Улучшена интеграция в `UsefulToolsSection`

### Technical
- Проект переведён на value-based animation (без `withAnimation` предупреждений)
- Обновлён `InGermany.xcodeproj` для поддержки новых файлов

---

## [v1.15.1] – 2025-10-15

### Changed
- 🎨 **PDF Library UI**:
  - Переписан экран `PDFLibraryView` с использованием карточек (`card layout`) вместо стандартного списка
  - Добавлены иконки `doc.richtext` для каждого документа
  - Улучшены отступы, фон и тени для более современного внешнего вида

---

## [v1.15.0] – 2025-10-14

### Added
- 📄 **PDF Library** — новый раздел для работы с PDF-документами:
  - `PDFLibraryView` — экран со списком документов
  - `PDFLibraryViewModel` — управление документами и локализация названий/описаний
  - `PDFViewerViewModel` — восстановлен и унифицирован для отображения PDF
  - Тестовые документы `test1.pdf`, `test2.pdf`, `test3.pdf` добавлены в `Resources/`

### Changed
- 🔗 В `UsefulToolsSection` ссылка на одиночный PDF заменена на переход в библиотеку PDF
- 🧩 `AppContainer` расширен фабрикой `makePDFLibraryViewModel()` для DI

### Localization
- 🌍 Добавлены ключи для PDF-документов (`pdf_title_*`, `pdf_desc_*`) во все 7 языков (ru, en, de, tj, fa, ar, uk)

---

## [v1.14.0] – 2025-10-13

### Added
- Принят **system Liquid Glass TabBar** на iOS 18+ (соответствует Apple Music/Safari look & feel)
- Автоматическое переключение: iOS 18+ → Liquid Glass, iOS 17 → blur fallback

### Changed
- Удалены неподдерживаемые ручные модификаторы (`.tabBarStyle`, `.tabBarMinimizeBehavior`)
- Упрощён `ContentView` для использования нативного `TabView` поведения

### Internal
- Проверена совместимость на iPhone 16 Pro Max (iOS 26.1)
- Обеспечен fallback blur styling для старых устройств (iOS 17)

---

## [v1.13.5] – 2025-10-12

### Changed
- **DemoArticleView** перемещён из отдельной вкладки TabBar в **Settings → Debug section**
- TabBar теперь ограничен 5 вкладками (Home, Categories, Search, Favorites, Settings)
- Demo content изолирован только для debug сборок

---

## [v1.13.4] – 2025-10-11

### Performance
- **perf(startup):** Переписан `DataService` → убраны блокирующие вызовы `Data(contentsOf:)`, добавлены `AsyncStream` для подписки на данные и быстрые `getCached…()` методы для мгновенного UI
- **perf(startup):** Обновлён `AppContainer.bootstrap()` → теперь запускает preload данных в фоне через `Task.detached` (UI не блокируется)
- **perf(startup):** В `InGermanyApp` убран `await` при вызове `bootstrap()`, вместо этого preload вызывается неблокирующе в `.onAppear`
- **perf(startup):** В `ContentView` добавлен вызов `appContainer.bootstrap()` в `.onAppear` как запасной запуск; все вкладки обёрнуты в `LazyView` для ленивой инициализации
- **perf(startup):** В `LocalizationManager` добавлен метод `preload()` для подготовки словарей; вызов интегрирован в `AppContainer.bootstrap()` → убран лаг на первом `t(_:)`

---

## [v1.13.3] – 2025-10-10

### Fixed
- Навигация в Categories flow:
  - Мигрирован `CategoriesView` на `NavigationStack`
  - Обновлён `ArticlesByCategoryView` на modern navigation API
  - Обеспечено соответствие `Article` и `Category` протоколу `Hashable` для стабильной навигации
  - Исправлен баг, когда статьи не были кликабельны или закрывались сразу после открытия

### Changed
- Добавлен глобальный переключатель тёмной темы через @AppStorage
- Добавлена реализация `Article.wordCount(for:)`
- Использован optional languageCode identifier с default в SettingsViewModel и SearchViewModel
- Удалён устаревший CardStyle enum

---

## [v1.13.2] – 2025-10-09

### Changed
- **ContentView**: убран лишний `forced cast` для `ReadingStatsManager`
- **AppContainer / InGermanyApp**: частичный рефакторинг DI (упрощение и устранение избыточных зависимостей)
- **ArticleDetailViewModel / ArticleDetailView**: приведены ближе к SOLID, подготовка к выносу UI-логики и шаринга

### Fixed
- Удалён ненужный `as! ReadingStatsManager` в ContentView
- Устранено предупреждение компилятора (Swift 6)

---

## [v1.13.1] – 2025-10-09

### Added
- Новый `ReadingStatsManager` и протокол `ReadingStatsManaging`
- Поддержка расчёта прогресса чтения, сессий и статистики

### Changed
- DI в `AppContainer` обновлён под ReadingStatsManager
- Все ViewModel переведены на использование `ReadingStatsManaging`
- RecentlyReadSection получает статьи через ReadingStatsManager

### Removed
- Удалён `ReadingHistoryManager` как устаревший компонент

---

## [v1.13.0] – 2025-10-07

### Fixed
- Исправлена ошибка инициализации `SettingsViewModel` через `AppContainer`
- Устранены ошибки подписки на `@AppStorage` с Combine (`dropFirst().sink`)
- Обновлён `LanguagePickerView`: добавлена поддержка внешнего `Binding<String>`

---

## [v1.12.5] – 2025-10-06

### Architecture & DI Refactoring
- **DI Foundation**: Созданы repository protocols (`ArticlesRepositoryProtocol`, `CategoriesRepositoryProtocol`, `FavoritesManagingProtocol`)
- **AppContainer**: Рефакторинг для использования protocol-based dependencies вместо конкретных реализаций
- **ViewModel Layer**: Обновлены все ViewModels для совместимости с правильным DI
- **Service Layer**: `ArticlesRepositoryImpl` теперь требует явной инъекции DataService
- **Testing**: Обновлён test suite для работы с новой DI архитектурой

### Fixed
- **Convenience Initializers**: Исправлены convenience инициализаторы ViewModel для правильной инъекции зависимостей
- **Swift 6 Concurrency**: Решены проблемы MainActor изоляции в AppContainer
- **Protocol Adoption**: Обеспечено использование протоколов вместо прямых зависимостей

---

## [v1.12.4] – 2025-10-05

### Tests - COMPLETE UNIT TESTING COVERAGE 🎉
- ALL COMPONENTS TESTED: 21/21 components с 300+ unit тестами
- **Models**: Article (26), Category (24), Location (22) - 72 tests total
- **Helpers**: ReadingTimeCalculator (60+), ReadingTimeTracker (30+), ReadingProgressTracker (25) - 115+ tests total
- **ViewModels**: 8 ViewModels с полным покрытием
- **Managers**: 4 managers с комплексным тестированием
- **Services**: 3 services с integration testing

### Architecture
- Swift 6 Ready: Полная MainActor изоляция и concurrency безопасность
- Performance Optimized: Performance тесты для всех критических операций
- Multilingual Support: Тестирование для всех 7 поддерживаемых языков
- Real Data Integration: Тесты используют актуальные JSON данные из project resources

---

## [v1.12.3] – 2025-10-05

### Fixed
- Исправлены ошибки компиляции в ArticleDetailViewModelTests:
  - Убран несуществующий параметр readingTime из markAsRead()
  - Заменены тесты computed properties на тесты реальной логики
  - Решены проблемы с MainActor изоляцией в конкурентных тестах

### Tests
- ArticleDetailViewModelTests теперь имеет полное покрытие:
  - Управление избранным и историей чтения
  - Логика фильтрации связанных статей
  - Локализация и edge-кейсы
  - Performance-тесты основных операций

### Changed
- Улучшена изоляция тестов с clearForTesting()
- Стандартизированы паттерны тестирования

---

## [v1.12.2] – 2025-10-04

### Added
- Unit-тесты для CategoryManager (загрузка, поиск по id и имени)
- Edge-тесты для DataService (articles.json, categories.json)

---

## [v1.12.1] – 2025-10-04

### Added
- Полное покрытие проекта `///` doc-комментариями для всех уровней:
  Core, Models, Managers, Services, UIUtils, ViewModels, Views (Components, Cards, Sections, Screens)

### Changed
- Код соответствует принципам Clean Code и SOLID
- Улучшена документация для автогенерации Xcode DocC

---

## [v1.12.0] – 2025-10-03

### Fixed
- Исправлено отображение миниатюр статей, загружаемых из Bundle
- Добавлена обработка расширений файлов (.avif → .jpg)
- Добавлен fallback для изображений без расширения
- Улучшена надёжность загрузки миниатюр

### Added
- Добавлены `///` doc-комментарии к основным моделям, менеджерам, сервисам, утилитам и view model
- Обновлён `CLEAN_CODE_CHECKLIST.md` с пунктом о документировании публичных классов и методов

---

## [v1.11.0] – 2025-10-03

### Fixed
- Восстановлено отображение миниатюр статей в `SearchView` и `FavoritesView` (загрузка изображений из Bundle вместо Asset Catalog)
- Исправлено вычисление `imageName` в `Article.swift` (автоматическая подстановка `.jpg`, замена `.avif`)
- Перенесён блок рейтинга (`StarRatingView`) под дату публикации в `ArticleRow`
- Добавлены локализованные изображения `.jpg` в `Resources/Images`, удалены устаревшие `.avif`
- Добавлена отладка загрузки статей в `DataService` и проверки ресурсов в `InGermanyApp`

### Changed
- Визуальное выравнивание блока рейтинга (`StarRatingView`) — теперь он отображается под датой публикации
- Небольшие улучшения верстки `ArticleRow` для более аккуратного отображения миниатюры и текста

---

## [v1.10.0] – 2025-10-03

### Changed
- Проектная структура оптимизирована под SOLID и MVVM:
  - Удалена папка `Utils/`
  - Файлы перемещены в новые пакеты:
    - `Protocols/` — для интерфейсов (ArticlesRepository, CategoriesRepository, KeyValueStore)
    - `Services/` — для реализаций (ArticlesRepositoryImpl, DataService, NetworkService, ShareService, AuthService, DefaultsStore, ExportToPDF, LocalizationManager)
    - `Managers/` — для state-менеджеров (FavoritesManager, RatingManager, ReadingHistoryManager, ReadingTimeTracker, TextSizeManager, ReadingProgressHelper, ReadingProgressTracker, ReadingTimeCalculator)
    - `UIUtils/` — для утилит UI (CardImageStyle, CardSize, Color+Hex, Theme, Animations, ProgressBar)
    - `Formatters/` — для сервисов форматирования (ArticleMetaFormatter и др.)

---

## [v1.9.0] – 2025-10-03

### Added
- Отображение и редактирование рейтинга статей в `ArticleCardView` через `StarRatingView`
- Интеграция `StarRatingView` в `ArticleCompactCard` и `ArticleMetaView` с использованием `RatingManager`

### Fixed
- Устранена ошибка вызова несуществующего свойства `rating` в `ArticleMetaView` и `ArticleCompactCard`, заменено на корректный метод `getRating(for:)`

---

## [v1.8.0] – 2025-10-03

### Changed
- `CategoriesView` переведён на MVVM через `CategoriesViewModel`
- Все зависимости теперь предоставляются через `AppContainer`
- `FavoritesView` полностью переведён на MVVM через `FavoritesViewModel`, убран прямой доступ к `FavoritesManager.shared`
- `AboutView` переведён на MVVM через `AboutViewModel`
- `ArticleDetailView` переведён на MVVM через `ArticleDetailViewModel`
- `SettingsView` переведён на MVVM через `SettingsViewModel`

---

## [v1.7.0] – 2025-10-03

### Added
- `AppContainer` как Composition Root для DI
- Фабрики: `makeHomeViewModel`, `makeFavoritesViewModel`, `makeSearchViewModel`
- Новые ViewModels: `FavoritesViewModel`, `SearchViewModel`

### Changed
- `HomeView`, `FavoritesView`, `SearchView` переведены на MVVM через DI
- Убраны прямые вызовы `FavoritesManager.shared` и `DataService` из Views
- `ContentView` обновлён для поддержки новой архитектуры

---

## [v1.6.0] – 2025-09-28

### Added
- Статистика чтения теперь учитывает секунды и отображается в формате ЧЧ:ММ:СС
- Ползунок для изменения размера текста с диапазоном от 80% до 150%

### Fixed
- Очистка истории чтения теперь синхронизируется с трекером времени (`ReadingTimeTracker`)
- Добавлены вызовы `startSession` и `endSession` в ArticleDetailView для корректного трекинга времени

---

## [v1.5.0] – 2025-09-27

### Fixed
- **Массовое исправление после рефакторинга менеджеров:**
  - Заменён `CategoriesStore` на `CategoriesRepository` во всех View
  - Исправлены API вызовы менеджеров (`FavoritesManager`, `RatingManager`, `TextSizeManager`)
  - Удалён `ReadingTracker` и устаревшие методы
  - Обновлены Preview с использованием `.shared` инстансов

### Refactored
- **Архитектура менеджеров:**
  - Все менеджеры переведены на использование общего `DefaultsStorage`
  - Унифицированный стиль синглтонов (`static let shared`, приватные ключи)
  - Введён `CategoriesRepository`, объединивший `CategoryManager` и `CategoriesStore`
  - Создана папка `Managers/` для централизованного хранения менеджеров

---

## [v1.4.0] – 2025-09-26

### Added
- 🌍 Поддержка трёх новых языков: **фарси (fa)**, **арабский (ar)**, **украинский (uk)**
- 🏷 Локализация тегов и категорий через `LocalizationManager`
- ⭐ Новый компонент `StarRatingView` (оценка статей)
- 📐 Панель настройки текста (`TextSizeSettingsPanel`)
- 📊 Трекер прогресса чтения (`ReadingProgressTracker` + `ReadingProgressHelper`)
- 📌 Компонент `LanguagePickerView` для смены языка

### Changed
- `ArticleView` и `ArticleDetailView`: 
  - добавлен рейтинг,
  - добавлено время чтения,
  - рекомендации «Вам может понравиться»,
  - кнопки поделиться и изменения размера текста

---

## [v1.3.0] – 2025-09-25

### Added
- Новый компонент `ArticleMetaView` для отображения категорий, дат публикации и бейджей `NEW/UPDATED`
- Поддержка относительных дат («2 дня назад», «вчера»)
- Переключатель «Относительные даты» в настройках (`SettingsView`)
- Цветные иконки категорий в `CategoriesView`

### Changed
- Обновлён дизайн статей:
  - `ArticleRow`, `ArticleView`, `ArticleDetailView` теперь используют `ArticleMetaView`
  - Улучшен вывод метаданных и анонсов

---

## [v1.2.0] – 2025-09-24

### Added
- Подключён **SwiftLint** для проверки качества кода
- Добавлен файл `.swiftlint.yml` с базовыми правилами для проекта

### Fixed
- Исправлен путь `xcode-select`, чтобы SwiftLint корректно работал с Xcode

---

## [v1.1.0] – 2025-09-22

### Added
- 8 новых полноформатных статей:
  - Жильё (аренда квартиры: документы, депозиты, подводные камни)
  - Steuer-ID (налоговый номер)
  - Deutschlandticket (проездной за 49 €)
  - Kindergeld (детское пособие)
  - Arbeitsvertrag (трудовой договор)
  - Probezeit (испытательный срок)
  - Kündigungsfrist (сроки увольнения)
  - Krankenversicherung (медицинская страховка)

### Changed
- Улучшено наполнение контента: статьи теперь длинные, структурированные и похожи на блоги

---

## [v1.0.0] – 2025-09-20

### Added
- Базовый каркас приложения InGermany (SwiftUI, iOS 17+)
- Статьи из локальных JSON
- Категории и теги
- Мультиязычность (RU/EN/TJ)
- Избранное
- Тёмная тема
- Карта с локациями
- Поддержка PDF-документов
- Фильтрация статей по тегам


---

## Links
[v0.3.0-f4-stabilization]: https://github.com/UmedTJK/InGermany/releases/tag/v0.3.0-f4-stabilization
[v0.2.3-di-localization-clean]: https://github.com/UmedTJK/InGermany/releases/tag/v0.2.3-di-localization-clean
[v0.2-di-refactor]: https://github.com/UmedTJK/InGermany/releases/tag/v0.2-di-refactor
