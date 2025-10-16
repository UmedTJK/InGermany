# AI_CONTEXT.md

## 1. Общая информация

**Название проекта:** InGermany  
**Разработчик:** @UmedTJK (GitHub: [InGermany](https://github.com/UmedTJK/InGermany))  
**Тип:** iOS-приложение (SwiftUI)  
**Цель:**  
Мультиязычный справочник для экспатов в Германии. Приложение помогает адаптироваться в новой стране через статьи, справочники, карты, полезные инструменты и персонализированные функции (избранное, история, прогресс чтения, статистика).  

**Платформа:** iOS 17+  
**Язык:** Swift 5.9  
**Текущая версия:** v1.15.0 (13 октября 2025)  
**Архитектура:** MVVM + Repository Pattern + Dependency Injection через `AppContainer`  
**Тесты:** 300+ Unit и UI тестов (XCTest)  
**Git Workflow:** Feature branches + Conventional Commits + автоматические релизы через скрипты (`release.sh`, `release_v2.sh`)  

---

## 2. Цели проекта

1. Создать удобное iOS-приложение-справочник для жизни в Германии.  
2. Реализовать мультиязычность (7 языков: RU, EN, TJ, DE, FA, AR, UK).  
3. Обеспечить поддержку офлайн-режима (offline-first) через кэширование данных(- 📦 Offline-First: уже реализован трёхуровневый кэш (Memory → File Cache → Bundle) с TTL и фоновой синхронизацией.).  
4. Разработать архитектуру с жёстким соблюдением принципов MVVM, SOLID и DI.  
5. Сформировать showcase-проект для портфолио Junior → Middle iOS Developer.  
6. Поддерживать прозрачную систему версионирования и документации (CHANGELOG, project_tree, AI_CONTEXT).  

---

## 3. Архитектура

### 3.1 Общая схема
- **Core Layer** — точка входа, DI-контейнер (`AppContainer`), главный App.  
- **Managers Layer** — бизнес-логика (избранное, рейтинги, история, статистика, категории, текстовые настройки и др.).  
- **Models Layer** — структуры данных (`Article`, `Category`, `Location`, статистика чтения и др.).  
- **Protocols Layer** — контракты для репозиториев и сервисов (ArticlesRepositoryProtocol, LocalizationManagerProtocol и др.).  
- **Services Layer** — работа с данными и инфраструктурой (DataService, NetworkService, LocalizationManager, ShareService, ExportToPDF и др.).  
- **Repositories Layer** — реализация доступа к данным (например, `ArticlesRepositoryImpl`).  
- **ViewModels Layer** — бизнес-логика экранов (SearchViewModel, ArticleDetailViewModel и др.).  
- **Views Layer** — экраны, секции и UI-компоненты (HomeView, SettingsView, ArticleDetailView, ArticleBlockView и др.).  
- **UIUtils Layer** — стили, анимации, утилиты, кастомный TabBar.  
- **Formatters Layer** — (зарезервировано, ожидается подключение).  
- **Tests Layer** — Unit и UI тесты (Mocks, Unit, UI, Resources).  

### 3.2 Архитектурные принципы
- **MVVM:** разделение UI и бизнес-логики.  
- **SOLID:** слабое связывание, интерфейсы через протоколы.  
- **Dependency Injection:** фабрики в `AppContainer`, передача зависимостей в конструкторы ViewModel.  
- **SwiftUI-first:** все экраны реализованы через SwiftUI.  
- **Async/await:** для загрузки данных (DataService, NetworkService).  
- **Offline-first:** приоритет локальных данных, затем кэш, затем сеть.  

---

## 4. Git и документация

- **Ветки:**  
  - `main` — стабильная ветка  
  - `feature/*` — новые фичи  
  - `fix/*` — исправления багов  
  - `refactor/*` — архитектурные изменения  
  - `docs/*` — документация  

- **Conventional Commits:**  
  - `feat:` — новая функциональность  
  - `fix:` — исправления  
  - `refactor:` — изменения без нового функционала  
  - `docs:` — документация  
  - `perf:` — оптимизации  
  - `test:` — тесты  

- **Автоматизация:**  
  - `release.sh` и `release_v2.sh` → автоматическое создание релизов, changelog и git-тегов (`vX.Y.Z-YYYYMMDD`).  
  - `update_project_tree.sh` → обновляет `Docs/project_tree.md`.  
  - `check_di_violations.sh` → фиксирует нарушения Dependency Injection.  

- **Документы:**  
  - `AI_CONTEXT.md` — источник правды о проекте (архитектура, файлы, roadmap).  
  - `CHANGELOG.md` — история версий.  
  - `CLEAN_CODE_CHECKLIST.md` — правила кода.  
  - `project_tree.md` — структура проекта.  




## 5. Core Layer

### InGermanyApp.swift
- Точка входа приложения.
- Инициализирует `AppContainer` и пробрасывает его через `EnvironmentObject`.
- Загружает главный UI:
  - либо стандартный `ContentView` (TabView),
  - либо кастомный `CustomTabBarView` (Liquid Glass стиль).
- Поддержка темной/светлой темы (через `@AppStorage("isDarkMode")`).

### ContentView.swift
- Корневой контейнер с вкладками (TabView).
- Вкладки:
  1. HomeView
  2. CategoriesView
  3. SearchView
  4. FavoritesView
  5. SettingsView
- Навигация построена на `NavigationStack`.
- Управление через `AppContainer`.

### AppContainer.swift
- Центральный **DI-контейнер**.
- Отвечает за создание и хранение зависимостей:
  - Managers (FavoritesManager, RatingManager, ReadingStatsManager, CacheManager и др.)
  - Services (DataService, LocalizationManager, ShareService, ExportToPDF и др.)
  - Repositories (ArticlesRepositoryImpl, CategoriesRepositoryProtocol).
- Содержит фабрики для создания ViewModels:
  - `makeSearchViewModel()`
  - `makeArticleRowViewModel(article:)`
  - `makeArticleDetailViewModel(article:allArticles:)`
  - `makeFavoritesViewModel()`
  - `makeCategoriesViewModel()`
  - `makeSettingsViewModel()`
  - и др.
- Обеспечивает строгий **Dependency Injection** (через конструкторы, а не глобальные синглтоны).
- Используется во всех Views для инициализации ViewModels.

---

## 6. Managers Layer

### FavoritesManager.swift
- `@MainActor`, `ObservableObject`.  
- Singleton `FavoritesManager.shared`.  
- Управляет списком избранных статей.  
- Хранение: `DefaultsStore`.  
- Свойства:  
  - `favorites: Set<String>` — набор избранных id.  
- Методы:  
  - `toggleFavorite(for:)` — переключает состояние избранного.  
  - `isFavorite(_:)` и `isFavorite(id:)` — проверка.  
  - `favoriteArticles(from:)` — фильтрация списка статей.  
  - `clearForTesting()` — очистка для тестов.  

---

### RatingManager.swift
- `@MainActor`, `ObservableObject`.  
- Singleton `RatingManager.shared`.  
- Управляет пользовательскими рейтингами статей.  
- Хранение: `UserDefaults`.  
- Свойства:  
  - `ratings: [String: Int]` — id статьи → рейтинг.  
- Методы:  
  - `getRating(for:)` — получить рейтинг.  
  - `setRating(_:for:)` — установить рейтинг.  
  - `clearForTesting()` — очистка.  

---

### ReadingHistoryManager.swift
- `@MainActor`, `ObservableObject`.  
- Singleton `ReadingHistoryManager.shared`.  
- Управляет **простым списком прочитанных статей**.  
- Хранение: локально (`DefaultsStore` в будущем).  
- Свойства:  
  - `readingHistory: [String: Date]` — id статьи → дата чтения.  
- Методы:  
  - `markAsRead(_:)` — отметить статью прочитанной.  
  - `isRead(_:)` — проверка.  
  - `lastReadDate(for:)` — дата последнего прочтения.  
  - `clearForTesting()` — очистка.  

---

### ReadingStatsManager.swift
- `@MainActor`, `ObservableObject`.  
- Singleton `ReadingStatsManager.shared`.  
- Реализует `ReadingStatsManagingProtocol`.  
- Управляет прогрессом, сессиями чтения, статистикой и историей.  
- Хранение: `DefaultsStore`.  
- Свойства:  
  - `progress: [String: CGFloat]` — прогресс по статьям.  
  - `completedSessions: [ReadingSession]`.  
  - `history: [ReadingHistoryEntry]`.  
- Методы:  
  - Прогресс: `updateProgress(for:value:)`, `progressForArticle(_:)`, `resetProgress(for:)`.  
  - Сессии: `startSession(articleId:)`, `endSession(articleId:)`, `currentReadingTime(for:)`.  
  - История: `addReadingEntry(articleId:readingTime:)`, `recentlyReadArticles(from:limit:)`, `isRead(_:)`, `lastReadDate(for:)`, `clearHistory()`.  
  - Статистика: `totalReadingTimeMinutes`, `totalArticlesRead`, `getStats()`.  
  - Поддержка: `estimateReadingTime(for:language:)`, `formatReadingTime(_:language:)`, `progressStatus(for:language:)`.  

---

### TextSizeManager.swift
- `@MainActor`, `ObservableObject`.  
- Singleton `TextSizeManager.shared`.  
- Управляет размером текста и поддерживает кастомный масштаб.  
- Хранение: `DefaultsStore`.  
- Свойства:  
  - `textSize: TextSize` (small, medium, large).  
  - `customScale: Double`.  
- Методы:  
  - `setTextSize(_:)` — выбор размера текста.  
  - Автосохранение при изменении.  
- Реализует `FontProviding`:  
  - `bodyFont`, `titleFont`, `headlineFont`, `captionFont`, `subheadlineFont`.  



## 7. Models Layer

### Article.swift
- Основная модель статьи.
- Поля:
  - `id`, `title`, `subtitle`, `content`
  - `tags`, `categoryID`, `createdAt`, `updatedAt`
  - `imageName` (опционально)
- Codable + Identifiable.
- Используется во всех слоях (UI, репозитории, менеджеры).

### Category.swift
- Категория статей.
- Поля:
  - `id`, `name`, `iconName`, `colorHex`
- Codable + Identifiable.
- Связь один-ко-многим со статьями.

### Location.swift
- Локации для карты.
- Поля:
  - `id`, `title`, `subtitle`
  - `latitude`, `longitude`
- Codable + Identifiable.
- Используется в `MapView`.

### ReadingHistoryEntry.swift
- Запись истории чтения.
- Поля:
  - `articleID`
  - `date`
- Codable.
- Хранится через `ReadingStatsManager`.

### ReadingSession.swift
- Сессия чтения статьи.
- Поля:
  - `articleID`
  - `startDate`
  - `endDate`
- Используется для вычисления времени чтения.

### ReadingStats.swift
- Статистика чтения.
- Поля:
  - `totalArticlesRead`
  - `totalReadingTime`
  - `averageReadingTime`
  - `currentStreak`
- Codable.
- Формируется `ReadingStatsManager`.

---

## 8. Protocols Layer

### FavoritesManagingProtocol.swift
- `@MainActor`.  
- Используется во ViewModel для доступа к `FavoritesManager`.  
- Методы:  
  - `isFavorite(_:) -> Bool` — проверка, находится ли статья в избранном.  
  - `toggleFavorite(for:)` — переключение состояния избранного.  

---

### RatingManagerProtocol.swift
- `@MainActor`.  
- Используется во ViewModel для доступа к `RatingManager`.  
- Методы:  
  - `getRating(for:) -> Int` — получить рейтинг статьи.  
  - `setRating(_:for:)` — установить рейтинг.  
  - `clearForTesting()` — очистить данные (например, для тестов).  

---

### ReadingStatsManagingProtocol.swift
- `@MainActor`.  
- Контракт для менеджера статистики чтения.  
- Методы:  
  - **Progress**: `updateProgress(for:value:)`, `progressForArticle(_:)`, `resetProgress(for:)`.  
  - **Sessions**: `startSession(articleId:)`, `endSession(articleId:)`, `currentReadingTime(for:)`.  
  - **History**: `addReadingEntry(articleId:readingTime:)`, `recentlyReadArticles(from:limit:)`, `isRead(_:)`, `lastReadDate(for:)`, `clearHistory()`.  
  - **Stats**: `totalReadingTimeMinutes`, `totalArticlesRead`, `getStats() -> ReadingStats`.  
  - **Helpers**: `estimateReadingTime(for:language:)`, `formatReadingTime(_:language:)`, `progressStatus(for:language:)`.  

---

### CategoriesRepositoryProtocol.swift
- `@MainActor`.  
- Репозиторий для работы с категориями.  
- Свойства:  
  - `categories: [Category]` — список категорий.  
- Методы:  
  - `bootstrap()` — первичная загрузка.  
  - `refresh()` — обновление данных.  
  - `category(by:) -> Category?` — поиск категории по id.  
  - `allCategories() -> [Category]` — список всех категорий.  
- ⚡ Включает реализацию `DefaultCategoriesRepository` (singleton).  

---

### ArticlesRepositoryProtocol.swift
- Контракт репозитория статей.  
- Методы:  
  - `loadArticles() async -> [Article]` — загрузить все статьи.  
  - `refreshArticles() async -> [Article]` — обновить данные.  
  - `getLastSource() async -> String` — источник данных (например, "local", "remote").  

---

### ArticleFormatterProtocol.swift
- Контракт для форматирования статей.  
- Методы:  
  - `formattedCreatedDate(_:, for:)` — форматированная дата создания.  
  - `formattedUpdatedDate(_:, for:)` — дата обновления.  
  - `relativeCreatedDate(_:, for:)` — относительная дата (например, "2 дня назад").  
  - `wordCount(_:, for:) -> Int` — подсчёт слов.  
  - `readingTime(_:, for:) -> Int` — оценка времени чтения.  
  - `formatReadingTime(_:, language:) -> String` — форматированное время чтения.  

---

### ShareServiceProtocol.swift
- `@MainActor`.  
- Контракт сервиса шаринга.  
- Методы:  
  - `generatePlainText(article:, selectedLanguage:)` — plain text.  
  - `generateFormattedText(article:, selectedLanguage:)` — форматированный текст.  
  - `showShareSheet(article:, selectedLanguage:)` — системное окно шаринга.  

---

### FontProviding.swift
- `@MainActor`.  
- Контракт для типографики.  
- Свойства:  
  - `bodyFont: Font`  
  - `titleFont: Font`  
  - `headlineFont: Font`  
  - `captionFont: Font`  
  - `subheadlineFont: Font`  

---

### LocalizationManagerProtocol.swift
- Контракт для менеджера локализации.  
- Свойства:  
  - `selectedLanguage: String` — текущий язык.  
- Методы:  
  - `getTranslation(key:, language:) -> String` — перевод по ключу.  
  - `t(_ key:, language:) -> String` — упрощённый доступ (автоопределение языка).  

---

### ReadingProgressTrackerProtocol.swift
- Контракт для трекинга прогресса чтения.  
- Методы:  
  - `progressForArticle(_:) -> Double` — прогресс по статье.  


---

## 9. Services Layer

### CacheService.swift
- `actor` (thread-safe).
- Унифицированный in-memory кэш с поддержкой TTL (time-to-live).
- Синглтон `CacheService.shared`.
- Методы:
  - `get(_ key:, lifetime:) -> T?`
  - `set(_ key:, value:)`
  - `clear(_ key:)`
  - `hasValidCache(_ key:, lifetime:) -> Bool`
- Применение: быстрый доступ к объектам без обращения к диску/сети.
- ⚠️ Ранее назывался `CacheManager`, перенесён в `Services/`.

### DataService.swift
- `actor` (thread-safe).
- Offline-first загрузка данных.
- Источники: Memory → Disk (CacheService) → Bundle → Network.
- Методы:
  - `articlesStream()`, `categoriesStream()`, `locationsStream()`
  - `loadArticles()`, `loadCategories()`, `loadLocations()`
  - `preloadAll()`
  - `clearCache()`, `refreshData()`
  - `getLastDataSource()`
- Использует: `CacheService`, `NetworkService`.

### NetworkService.swift
- Singleton для загрузки JSON (offline-first).
- Источники: Bundle → File Cache → Network (async refresh).
- Методы:
  - `loadJSON(from:)`
  - `loadJSONWithSource(from:)`
  - `clearCache()`
- Использует файловый кэш в директории `InGermanyCache`.

### LocalizationManager.swift
- ObservableObject + Singleton.
- Реализация `LocalizationManagerProtocol`.
- Управляет текущим языком через `@AppStorage("selectedLanguage")`.
- Хранит словари переводов.
- Методы:
  - `getTranslation(key:language:)`
  - `hasKey(_:)`
  - `preload()`

### ArticleFormatter.swift
- Реализация `ArticleFormatterProtocol`.
- Зависимости: `DateFormattingService`, `TextAnalysisService`.
- Методы:
  - `formattedCreatedDate`
  - `formattedUpdatedDate`
  - `relativeCreatedDate`
  - `wordCount`
  - `readingTime`
  - `formatReadingTime`

### ShareService.swift
- Реализация `ShareServiceProtocol`.
- Зависимости: `ArticleFormatter`, `LocalizationManager`.
- Методы:
  - `generatePlainText`
  - `generateFormattedText`
  - `showShareSheet`
- Показывает системный `UIActivityViewController`.

### ArticleRenderer.swift
- SwiftUI-вью для рендеринга JSON-статей.
- Поддерживает блоки:
  - paragraph, info, warning, tip, quote, checklist, faq, links, image, list.
- Используется в `ArticleDetailView`.

### ExportToPDF.swift
- Генерация PDF документов через `UIGraphicsPDFRenderer`.
- Методы:
  - `export(title:content:fileName:)`
- Сохраняет в `Documents/`.

### AuthService.swift
- Заготовка для аутентификации.
- TODO:
  - sign-in / sign-out
  - token storage
  - user session validation

### TextAnalysisService.swift
- Подсчёт слов и времени чтения.
- Поддержка разных скоростей чтения (de=180, en=200, ru=190, tj=170).
- Методы:
  - `wordCount(for:)`
  - `readingTime(for:language:)`

### DefaultsStore.swift
- Обёртка над `UserDefaults` с Codable.
- Методы:
  - `load(_:as:)`
  - `save(_:for:)`
  - `remove(_:)`

### DateFormattingService.swift
- Реализация `DateFormattingServiceProtocol`.
- Методы:
  - `formattedDate`
  - `relativeDate`

### ArticlesRepositoryImpl.swift
- Реализация `ArticlesRepositoryProtocol`.
- Методы:
  - `loadArticles()`
  - `refreshArticles()`
  - `getLastSource()`


## 10. Formatters Layer

### ReadingTimeCalculator.swift
- Утилита для расчёта времени чтения текста/статьи.
- Использует скорости чтения из `TextAnalysisService`.
- Методы:
  - `calculate(for text: String, language: String) -> Int`
- ⚠️ Перенесён из `Managers/` в `Formatters/`.


## 11. UIUtils Layer

### Animations.swift
- Набор `View`-модификаторов для анимаций.  
- Методы:  
  - `cardStyle()` — стандартный стиль карточки (фон, скругление, тень).  
  - `lightCardStyle()` — облегчённый стиль карточки с мягкой тенью.  
  - `scaleOnAppear()` — анимация масштаба при появлении.  
  - `pressAnimation()` — анимация при нажатии.  
  - `slideInAnimation(delay:)` — слайд-ин с прозрачностью.  

---

### CardStyle.swift
- Enum `CardStyle` (standard, light).  
- Реализует `CaseIterable`, `Identifiable`, `Codable`.  
- Свойства:  
  - `title` — локализуемое имя стиля.  
- Расширение `View`: метод `applyCardStyle(_:)` применяет соответствующий визуальный стиль карточки.  

---

### CardImageStyle.swift
- Enum `CardImageStyle` (allCorners, bottomCorners, fullWidth).  
- Реализует `CaseIterable`, `Identifiable`.  
- Свойства:  
  - `localizedTitle` — локализованное название стиля.  
- Используется в UI для настройки отображения изображений внутри карточек.  

---

### CardSize.swift
- Утилита для вычисления размеров карточек.  
- Методы:  
  - `width(for:) -> CGFloat` — рекомендуемая ширина карточки по ширине экрана.  
  - `height(for:screenWidth:) -> CGFloat` — рекомендуемая высота карточки по размеру экрана.  

---

### Color+Hex.swift
- Расширение `Color` с инициализатором из HEX-строки.  
- Поддерживает строки с `#` и без него.  
- Пример: `Color(hex: "#FF0000")`.  

---

### Environment+ScreenSize.swift
- Расширение `EnvironmentValues` для передачи размера экрана.  
- Свойство:  
  - `screenSize: CGSize` — доступ к размеру экрана через `@Environment(\.screenSize)`.  

---

### ProgressBar.swift
- SwiftUI-компонент прогресс-бара.  
- Свойства:  
  - `value: CGFloat` — от `0.0` до `1.0`.  
- Реализация: серый фон + синий индикатор, анимация `easeInOut`.  
- Применяется для отображения прогресса чтения или загрузки.  

---

### ReadingProgressHelper.swift
- Структура для управления визуализацией прогресса чтения.  
- Зависит от `LocalizationManager`.  
- Методы:  
  - `color(for:) -> Color` — цвет индикатора (зелёный, оранжевый, красный).  
  - `status(for:language:) -> String` — локализованная строка статуса (“Начало”, “В процессе”, “Почти готово”, “Готово”).  
  - `progressView(progress:, language:) -> some View` — комбинированный прогресс-бар с текстом.  

---

### RoundedCorner.swift
- Shape `RoundedCorner`.  
- Свойства:  
  - `radius: CGFloat` — радиус скругления.  
  - `corners: UIRectCorner` — скругляемые углы.  
- Расширение `View`: метод `cornerRadius(_:corners:)` для скругления конкретных углов.  

---

### Theme.swift
- Определяет глобальные константы стиля приложения.  
- Содержит:  
  - Цвета (`primaryBlue`, `secondaryGray`, `backgroundCard`, `backgroundMain`).  
  - Градиенты (`cardGradient`, `favoriteCardGradient`).  
  - Отступы (`smallPadding`, `mediumPadding`, `largePadding`, `cardPadding`).  
  - Радиус (`cardCornerRadius`).  
  - Тени (`cardShadow`, `lightShadow`).  
- Расширение `View`:  
  - `sectionCardStyle()` — стандартный стиль секции с отступами и тенью.  
  
  ### Accessibility+Extensions.swift
- Расширения для упрощения добавления доступности (VoiceOver).  
- Методы:  
  - `a11yLabel(_:)` — добавляет читаемую метку для VoiceOver.  
  - `a11yHint(_:)` — добавляет подсказку, которую VoiceOver озвучит.  
  - `a11yAddTraits(_:)` — добавляет атрибуты (например, “кнопка”).  
- Применяется для повышения доступности интерфейса.  

---

### ScaleOnTap.swift
- `ViewModifier`, добавляющий анимацию уменьшения при нажатии.  
- Реализует эффект “нажатой” кнопки или карточки.  
- Использует `@GestureState` для отслеживания касания.  
- Методы:  
  - `scaleOnTap()` — расширение для `View`, применяющее модификатор.  
- Пример: `Button("Tap me") { ... }.scaleOnTap()`.  




## 10. ViewModels Layer

### HomeViewModel.swift
- Управляет главным экраном (Home).
- Свойства:
  - `articles: [Article]`
  - `isLoading: Bool`
  - `dataSource: String`
  - `isShowingRandomArticle: Bool`
  - `randomArticle: Article?`
- Зависимости:
  - `FavoritesManager`
  - `ReadingStatsManaging`
  - `CategoriesRepositoryProtocol`
  - `ArticlesRepositoryProtocol`
  - `LocalizationManager`
- Методы:
  - `allCategories` (вычисляемое свойство)
  - `articlesByCategory` (группировка по категориям)
  - `categoryName(for:language:)`
  - `loadData()`, `refreshData()`
  - `selectRandomArticle()`

---

### SettingsViewModel.swift
- Управляет экраном настроек.
- Зависимости:
  - `LocalizationManager`
  - `ReadingStatsManaging`
- Свойства (через `@AppStorage`):
  - `selectedLanguage`
  - `isDarkMode`
  - `relativeDates`
  - `selectedCardStyleIndex`
- Дополнительно:
  - `isHistoryCleared`
  - `supportedLanguages`
  - `selectedCardStyle: CardImageStyle` (через индекс)
  - Статистика:
    - `totalArticlesRead`
    - `formattedTotalReadingTime`
    - `formattedAverageReadingTime`
    - `currentStreak`
- Методы:
  - `localizedText(_:)`
  - `displayName(for:)`
  - `clearHistory()` (с временным toast)
  - `resetToDefaults()`

---

### SearchViewModel.swift
- Управляет экраном поиска.
- Свойства:
  - `articles: [Article]`
  - `searchText: String`
  - `selectedTag: String?`
  - `isLoading: Bool`
  - `dataSource: String`
- Зависимости:
  - `FavoritesManager`
  - `CategoriesRepositoryProtocol`
  - `ArticlesRepositoryProtocol`
- Методы:
  - `filteredArticles` (computed)
  - `allTags` (computed)
  - `loadArticles()`

---

### FavoritesViewModel.swift
- Управляет списком избранных статей.
- Свойства:
  - `allArticles: [Article]`
  - `favoriteArticles: [Article]`
  - `isLoading: Bool`
  - `dataSource: String`
- Зависимости:
  - `FavoritesManager`
  - `ArticlesRepositoryProtocol`
- Методы:
  - `loadFavorites()`
  - `toggleFavorite(for:)`

---

### CategoriesViewModel.swift
- Управляет категориями и статьями в них.
- Свойства:
  - `categories: [Category]`
  - `articles: [Article]`
- Зависимости:
  - `CategoriesRepositoryProtocol`
  - `ArticlesRepositoryProtocol`
  - `FavoritesManager`
- Методы:
  - `load()`
  - `refresh()`
  - `category(by:)`
  - `articles(for:)`
  - Совместимость: `loadData()`

---

### ArticleRowViewModel.swift
- Для отображения строки/карточки статьи.
- Свойства:
  - `isFavorite: Bool`
  - `rating: Int`
  - `imageName: String?`
  - `categoryName: String`
  - `title`, `subtitle`, `contentPreview`
  - `metaInfo` (время, дата, и т.п.)
  - `progress: Double`
- Зависимости:
  - `LocalizationManager`
  - `FavoritesManager`
  - `RatingManager`
  - `CategoriesRepositoryProtocol`
  - `ReadingStatsManaging`
  - `ArticleFormatter`
- Методы:
  - `toggleFavorite()`
  - `setRating(_:)`

---

### ArticleDetailViewModel.swift
- Управляет экраном статьи.
- Свойства:
  - `article: Article`
  - `allArticles: [Article]`
  - `rating: Int`
  - `isFavorite: Bool`
  - `progress: Double`
- Зависимости:
  - `LocalizationManager`
  - `TextSizeManager`
  - `FavoritesManager`
  - `RatingManager`
  - `ReadingStatsManaging`
  - `ArticleFormatter`
  - `CategoriesRepositoryProtocol`
  - `ShareServiceProtocol`
- Методы:
  - Прогресс:
    - `handleScrollOffset(_:)`
    - `startReadingSession()`
    - `endReadingSession()`
  - Избранное/рейтинг:
    - `toggleFavorite()`
    - `setRating(_:)`
  - Рекомендации:
    - `relatedArticles(limit:)`
    - `recommendedArticles`
  - Локализация: `t(_:, lang:)`
  - Категории: `categoryName(for:)`
  - Шаринг: `shareContent`, `showShareSheet`
  - Дочерние VM: `createChildViewModel(for:)`
  - Lifecycle: `onAppear()`

---

### ArticleCompactCardViewModel.swift
- Для компактной карточки статьи.
- Зависимости:
  - `ReadingProgressTrackerProtocol`
  - `RatingManagerProtocol`
  - `CategoriesRepositoryProtocol`
  - `LocalizationManagerProtocol`
- Методы:
  - `category(for:)`
  - `categoryDisplay(for:)` (возвращает icon, name, colorHex)
  - `rating(for:)`
  - `setRating(_:)`
  - `readingProgress(for:)`
  - `t(_:)`

---

### PDFViewerViewModel.swift
- Для экрана PDF-просмотра.
- Зависимости: `LocalizationManager`.
- Методы:
  - `localizedPDFText(_:)`

---

### LocationsViewModel.swift
- Управляет локациями.
- Свойства:
  - `locations: [Location]`
  - `isLoading: Bool`
- Зависимости: `DataService`.
- Методы:
  - `loadLocations()`

---

### AboutViewModel.swift
- Управляет экраном "О приложении".
- Свойства:
  - `appVersion: String`
  - `buildNumber: String`
  - `repositoryURL: URL`
- Методы:
  - `loadVersionInfo()` (чтение Info.plist)

---

### ViewModels.swift
- Umbrella-файл.
- Собирает воедино ViewModels (для удобства импорта).
- Может содержать общие утилиты или typealias.


## 11. Views Layer

### Основные экраны

#### HomeView.swift
- Главный экран приложения.
- Зависимости: `HomeViewModel`, `AppContainer`.
- Элементы:
  - Индикация источника данных (цветная линия).
  - Секции:
    - `UsefulToolsSection`
    - `RecentlyReadSection`
    - `FavoritesSection`
    - `CategorySection`
    - `AllArticlesSection`
  - Навигация к случайной статье (`randomArticle`).
- Локализация: через `appContainer.localizationManager`.

#### SearchView.swift
- Экран поиска статей и категорий.
- Зависимости: `SearchViewModel`, `AppContainer`.
- Элементы:
  - Поиск через `.searchable`.
  - Фильтрация по тегам (`TagFilterView`).
  - Список найденных статей → `ArticleDetailView`.

#### FavoritesView.swift
- Экран избранного.
- Зависимости: `FavoritesViewModel`, `AppContainer`.
- Элементы:
  - Поиск по избранным.
  - Индикация источника данных.
  - Список статей → `ArticleDetailView`.

#### CategoriesView.swift
- Экран категорий.
- Зависимости: `CategoriesViewModel`, `AppContainer`.
- Элементы:
  - Список категорий с иконками и цветами.
  - Навигация → `ArticlesByCategoryView`.

#### ArticlesByCategoryView.swift
- Список статей выбранной категории.
- Зависимости: `AppContainer`.
- Элементы:
  - `List` со статьями.
  - Навигация → `ArticleDetailView`.

#### ArticlesByTagView.swift
- Список статей по тегу.
- Зависимости: `AppContainer`.
- Элементы:
  - Фильтрация по `tag`.
  - Навигация → `ArticleDetailView`.

#### ArticleDetailView.swift
- Экран полной статьи.
- Зависимости: `ArticleDetailViewModel`, `LocalizationManager`, `AppContainer`.
- Элементы:
  - Заголовок, категория, мета-информация (`ArticleMetaView`).
  - Прогресс-бар чтения (`ReadingProgressBar`).
  - Основной контент (с поддержкой `ArticleRenderer`).
  - Панель управления:
    - Изменение размера текста (`TextSizeSettingsPanel`).
    - Добавление в избранное.
    - Установка рейтинга (`StarRatingView`).
    - Шаринг.
  - Блок "Рекомендованные статьи".
- Жизненный цикл: `onAppear`, `onDisappear`.

#### AboutView.swift
- Экран "О приложении".
- Зависимости: `AboutViewModel`, `AppContainer`.
- Элементы:
  - Название приложения.
  - Версия и номер сборки.
  - Ссылка на GitHub.
- Локализация: ключи `about_*`.

#### MapView.swift
- Экран карты.
- Зависимости: `AppContainer`.
- Элементы:
  - Отображение локаций (`Location`).
  - Toolbar:
    - "Моё местоположение"
    - "Обновить"
- Локализация: `map_title`, `map_refresh`, `map_my_location`.

#### SettingsView.swift
- Экран настроек.
- Зависимости: `SettingsViewModel`, `AppContainer`.
- Секции:
  - Language (выбор языка)
  - Appearance (тёмная тема)
  - Card Style (Picker)
  - Date Format (Toggle)
  - Statistics (общее и среднее время, streak)
  - About (переход к AboutView)
  - Debug (только DEBUG) → DemoArticleView
  - Clear History (toast)
  - Reset Defaults
- Дополнительно: `HistoryClearedToast`.

#### DemoArticleView.swift
- Экран для отладки.
- Загружает тестовый JSON (`burgeramt_registration.json`).
- Использует `ArticleRenderer`.
- Только для Debug/Preview.

#### PDFViewer.swift
- Экран просмотра PDF.
- Зависимости: `LocalizationManager`.
- Элементы:
  - `PDFKitView` для отображения документа.
  - Сообщение, если PDF не найден.



Секции (Sections)
#### CategorySection.swift
- Горизонтальный список статей по категории.
- Использует `ArticleCompactCard`.
- Заголовок локализован.
- Навигация → `ArticleDetailView`.

#### FavoritesSection.swift
- Секция избранных статей.
- Заголовок: `section_favorites`.
- Горизонтальный список.
- Навигация → `ArticleDetailView`.

#### RecentlyReadSection.swift
- Секция последних прочитанных.
- Заголовок: `section_recently_read`.
- Отображает до 7 последних статей.
- Навигация → `ArticleDetailView`.

#### AllArticlesSection.swift
- Секция "Все статьи".
- Отображает весь список в горизонтальном скролле.
- Пока без локализации (фиксировано "Все статьи").

#### UsefulToolsSection.swift
- Секция "Полезные инструменты".
- Карточки:
  - MapView
  - PDFViewer
  - Random Article
- Локализация: `section_useful_tools`, `tool_map`, `tool_pdf_docs`, `tool_random_article`.


Компоненты (Components)
#### ArticleMetaView.swift
- Отображает метаданные статьи:
  - категория,
  - рейтинг,
  - время чтения,
  - дата публикации,
  - бейджи ("Новое", "Обновлено").

#### ReadingProgressBar.swift
- Горизонтальный прогресс-бар чтения.
- Свойства:
  - `progress`
  - `height`
  - `isReading`
- Локализация: "Прогресс чтения", "Чтение".

#### Components.swift
- Содержит UI-компоненты:
  - `ToolCard`
  - `RecentArticleCard`
  - `EmptyFavoritesView`
  - `CategoryFilterButton`

#### ArticleCompactCard.swift
- Компактная карточка статьи.
- Элементы:
  - Изображение/иконка.
  - Заголовок, подзаголовок.
  - Категория.
  - Теги.
  - Рейтинг.
  - Время чтения.


## 12. UIUtils Layer

### CustomTabBarView.swift
- Кастомный TabBar (Liquid Glass стиль).
- Использует `AppContainer` для внедрения зависимостей и `LocalizationManager` для локализации.
- Состоит из 5 вкладок:
  1. HomeView
  2. CategoriesView
  3. SearchView
  4. FavoritesView
  5. SettingsView
- Особенности:
  - Blur-материал (`.thinMaterial`) с градиентом.
  - Тень (`shadow`).
  - Анимация выбора вкладки через `spring` и `matchedGeometryEffect`.
  - Локализованные подписи (`localizationManager.t("tab_*")`).

---

### ArticleBlockView.swift
- Универсальный блок для текста (Info, Warning, Tip, Quote).
- Иконка (📘 ⚠️ 💡 ❝) и текст.
- Стилизация зависит от типа блока.
- Для `quote` используется курсив.

---

### ChecklistCardView.swift
- Компонент-чеклист.
- Элементы: `ChecklistItem { text: String, isDone: Bool }`.
- Иконки `checkmark.circle.fill` и `circle`.
- Возможность отмечать выполненные шаги.

---

### FAQBlockView.swift
- Аккордеон "Вопрос–Ответ".
- Вопрос с иконкой стрелки (`chevron.up / chevron.down`).
- Ответ раскрывается с анимацией `opacity + slide`.
- Стилизация: голубой фон, скругленные углы.

---

### ProgressBar.swift
- Универсальный горизонтальный прогресс-бар.
- Свойства:
  - `value: CGFloat` (от 0.0 до 1.0).
- Реализация:
  - Серый фон.
  - Синий индикатор с анимацией `.easeInOut`.

---

### ReadingTimeCalculator.swift
- Enum-утилита для вычисления времени чтения.
- Методы:
  - `estimateReadingTime(for:text, language:, wordsPerMinute:)` → минуты.
  - `formatReadingTime(_:language:)` → строка (`"мин"`, `"min"`, и др.).
- Поддержка мультиязычности (RU/EN).

---

### Environment+ScreenSize.swift
- Расширение для `EnvironmentValues`.
- Позволяет получать размер экрана:  
  ```swift
  @Environment(\.screenSize) var screenSize

### Animations.swift
⚠️ Файл не предоставлен.  
Ожидается: набор ViewModifier/extension для анимаций (`scaleOnAppear`, `pressAnimation`, `slideInAnimation`).

---

### CardImageStyle.swift
⚠️ Файл не предоставлен.  
Ожидается: enum для стиля изображений карточек (none, small, medium, large) + локализованный `title`.

---

### CardStyle.swift
⚠️ Файл не предоставлен.  
Ожидается: enum для стиля карточек (light/dark/outlined) + модификатор `applyCardStyle()`.

---

### CardSize.swift
⚠️ Файл не предоставлен.  
Ожидается: enum для размеров карточек (small, medium, large).

---

### Accessibility+Extensions.swift
⚠️ Файл не предоставлен.  
Ожидается: расширения для улучшения доступности (label, hint, traits).



## 13. Formatters Layer

### ReadingTimeCalculator.swift
- `struct` (утилита без состояния).  
- Используется для оценки времени чтения текста.  
- Поддерживает языки: `ru`, `en`, `de`, `tj`.  
- Методы:  
  - `estimateReadingTime(for:, language:) -> Int` — оценка времени чтения в минутах.  
  - `formatReadingTime(_:, language:) -> String` — форматированная строка (“3 мин чтения”, “3 min read”).  
- Реализует простую подсчётную логику слов и скорости чтения (WPM).  

---

### ArticleFormatter.swift
- Класс для форматирования метаданных статей.  
- Зависимости: `DateFormattingServiceProtocol`, `TextAnalysisServiceProtocol`.  
- Методы:  
  - `formattedCreatedDate(_:, for:)` — дата создания.  
  - `formattedUpdatedDate(_:, for:)` — дата обновления.  
  - `relativeCreatedDate(_:, for:)` — относительная дата (“2 дня назад”).  
  - `wordCount(_:, for:) -> Int` — подсчёт слов.  
  - `readingTime(_:, for:) -> Int` — расчёт времени чтения.  
  - `formatReadingTime(_:, language:) -> String` — компактное форматирование (“3 мин.”).  
- ⚡ Реализует `ArticleFormatterProtocol`.  
- Имеет встроенные fallback-переводы для случаев, когда дата отсутствует.  

---

### DateFormattingService.swift
- Реализует `DateFormattingServiceProtocol`.  
- Singleton `DateFormattingService.shared`.  
- Методы:  
  - `formattedDate(_:, for:)` — локализованная дата.  
  - `relativeDate(_:, for:)` — относительное время (“вчера”, “2 дня назад”).  
- Использует:  
  - `DateFormatter` (medium style).  
  - `RelativeDateTimeFormatter` (full style).  
- Поддержка локалей: `ru_RU`, `en_US`, `de_DE`, `tj → ru_RU`.  


## 14. Tests Layer

### Структура тестов
- **InGermanyTests.swift** — базовый файл тестов.
- **Models/**
  - `ArticleTests.swift` — тесты модели `Article`:
    - локализация заголовка и контента,
    - работа с датами (createdAt, updatedAt),
    - форматирование дат и относительных дат,
    - обработка изображений (расширения, AVIF → JPG),
    - wordCount и readingTime,
    - флаги `isNew`, `isUpdatedRecently`,
    - Hashable/Equatable.
  - `CategoryTests.swift` — тесты модели `Category`:
    - инициализация, кодирование/декодирование,
    - локализация названий (RU, EN, DE, TJ, FA, AR, UK),
    - фолбэки (английский, первый доступный, «No name»),
    - sampleCategories и JSON-структуры,
    - performance-тесты.
  - `LocationTests.swift` — тесты модели `Location`:
    - инициализация, кодирование/декодирование,
    - проверка координат (`CLLocationCoordinate2D`),
    - реальные данные (Посольство Германии в Душанбе, Ausländerbehörde Hildburghausen, Bürgeramt Berlin),
    - валидные и экстремальные координаты,
    - equality по id,
    - performance-тесты.
- **Managers/**
  - `ReadingTimeCalculatorTests.swift`:
    - оценка времени чтения для RU/EN/DE/TJ,
    - фолбэки для неизвестных языков,
    - работа с пустыми и спецтекстами,
    - форматирование строк времени чтения,
    - поддержка всех языков,
    - edge cases (эмодзи, спецсимволы, пустые строки),
    - performance-тесты,
    - интеграция с моделью `Article`.
- **Mocks/**
  - `MockArticlesRepository.swift` — мок-репозиторий статей.
  - `MockCategoriesRepository.swift` — мок-репозиторий категорий.
  - `MockDataService.swift` — универсальный мок для статей/категорий.
- **Resources/**
  - `sample_articles.json` — примеры статей (Bank Account, Health Insurance).
  - `sample_categories.json` — примеры категорий (Finance, Health).
- **UI/**
  - `AppUITests.swift` (структура зафиксирована в дереве, содержимое не предоставлено).

### Покрытие
- >300 Unit и UI тестов (XCTest).  
- Модели протестированы на инициализацию, локализацию, сериализацию, edge cases.  
- Менеджеры протестированы на корректность вычислений, фолбэки и производительность.  
- Используются моки и тестовые JSON-ресурсы.  


## 15. Resources Layer

### JSON-данные
- **articles.json**  
  Основной источник статей (id, заголовок, контент, теги, категории, даты создания/обновления, изображения).  
  Используется как локальный источник для `ArticlesRepository`.

- **categories.json**  
  Список категорий статей.  
  Поддерживает мультиязычность (RU, EN, DE, TJ).  
  Каждая категория содержит id, названия на разных языках, иконку и цвет.

- **locations.json**  
  Геолокации (посольства, Bürgeramt, Ausländerbehörde).  
  Каждая запись содержит id, название, широту и долготу.

- **burgeramt_registration.json**  
  Пример статьи в расширенном формате.  
  Содержит параграфы, info/warning блоки, списки, чек-листы, FAQ, цитаты и ссылки.  
  Используется для теста рендеринга сложных статей (`ArticleRenderer`).

### Локализация
- **Localizable.xcstrings**  
  Центральный файл локализаций Xcode.  
  Хранит переводы для всех поддерживаемых языков (RU, EN, DE, TJ, FA, AR, UK).  
  Используется через `LocalizationManager.t(key)`.

### PDF-документы
- **insurance.pdf** — тестовый PDF о медицинской страховке.  
- **burgergeld.pdf** — тестовый PDF о Bürgergeld.  
- **guide.pdf** — общий тестовый гид.  

Все PDF-файлы используются как примеры для функции `PDFViewer`.



## 16. Scripts Layer

В проекте реализован набор bash/zsh-скриптов для автоматизации рабочих процессов.

### Release Scripts
- **release.sh**
  - Простейшая версия: принимает `VERSION` и `MESSAGE` как аргументы.
  - Добавляет запись в `Docs/CHANGELOG.md`, делает коммит и создаёт тег `vX.Y.Z-YYYYMMDD`.
- **release_v2.sh**
  - Определяет последнюю версию по тегу.
  - Предлагает выбор (патч/минор/мажор).
  - Обновляет `Docs/CHANGELOG.md`, делает коммит и пуш с тегом.
- **release_v3.sh**
  - Автоматически вычисляет следующую версию (патч).
  - Извлекает коммиты и категоризирует: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `style`.
  - Генерирует CHANGELOG с блоками.
- **release_v4.sh**
  - Патч-ориентированный релиз.
  - Категоризация коммитов (`feat`, `fix`, `docs`), добавляется в CHANGELOG.
- **release_v5.sh**
  - Поддерживает категории: Features, Fixes, Docs, Other.
  - Увеличивает только PATCH.
- **release_v6.sh**
  - Добавляет выбор уровня релиза (patch/minor/major).
  - CHANGELOG формируется с эмодзи: ✨, 🛠, 📝, 🔧, 🧱, 🧪.
- **release_v7.sh** (актуальная версия)
  - Полная поддержка Conventional Commits.
  - Категоризация: 💥 Breaking Changes, ✨ Features, 🛠 Fixes, 📝 Docs, 🔧 Chores, 🧱 Refactors, 🧪 Tests.
  - Автоматически обновляет `Docs/CHANGELOG.md`, делает коммит, пуш и тегирование.
  - Рекомендуется как основной скрипт релизного процесса.

### Utility Scripts
- **tag_with_date.sh**
  - Создаёт тег с датой: `vX.Y.Z-YYYYMMDD`.
  - Используется для ручного управления версиями.
- **update_project_tree.sh**
  - Генерирует `Docs/project_tree.md` (по умолчанию глубина 3).
  - Игнорирует `Pods`, `Carthage`, `DerivedData`, `build`, `.git`.
  - Делает коммит с сообщением `docs(tree): обновлён Docs/project_tree.md`.

---

📌 Таким образом, папка `scripts/` полностью покрывает процессы:  
- Версионирование, релизы и CHANGELOG,  
- Создание тегов,  
- Автоматическое обновление дерева проекта.



## 17. Docs Layer6
В папке `Docs/` собраны справочные материалы, служебные файлы и внутренние инструкции для проекта **InGermany**.

### Основные документы

- **README.md**  
  Обновлённая версия `AI_CONTEXT.md` от 11.10.2025.  
  Содержит актуальное описание архитектуры, менеджеров, сервисов и планов.  
  Старый `Docs/AI_CONTEXT.md` оставлен для истории.

- **UIUTILS_GUIDE.md**  
  Полный справочник по утилитам `UIUtils/`.  
  Описаны все реализованные расширения и эффекты (Color+Hex, Theme, CardStyle, Animations, ShimmerEffect и др.) с примерами использования.  
  Используется для демонстрации архитектуры на собеседованиях.

- **ARCHITECTURE_ISSUES.md**  
  Журнал архитектурных проблем и их решений.  
  Зафиксировано: к 10.10.2025 (v1.14.1+) все критические архитектурные проблемы решены, DI стабилен, offline-first реализован с трёхуровневым кэшем.

- **di_refactoring_progress.md**  
  Лог прогресса DI-рефакторинга.  
  Поэтапно фиксирует перевод ArticleDetailView, ArticleMetaView, ArticleCardView и др. на конструкторный DI.

- **next_steps.md**  
  Roadmap развития проекта:  
  - Junior+ (реализовано),  
  - цель — Middle showcase (unit/UI тесты, SwiftData, CI/CD),  
  - опционально движение к Senior (Clean Architecture, multiplatform, advanced testing).

- **locations_README.md**  
  Документация к `locations.json`.  
  Описывает структуру геообъектов (id, name, latitude, longitude), примеры (Посольство Германии в Душанбе, Bürgeramt Berlin).

- **CLEAN_CODE_CHECKLIST.md**  
  Чеклист качества кода: архитектура, локализация, тесты, Git, документация, стиль.  
  Используется для регулярного самоаудита.

- **git_snapshot.md**  
  Снимок состояния репозитория на 25.09.2025:  
  - активная ветка `feature/article-images`,  
  - последний релизный тег v1.8.4,  
  - список последних коммитов,  
  - рекомендации по обновлению.

- **PROMPTS_FOR_AI_AGENTS.md**  
  Шаблоны промптов для ИИ-ассистента (короткий, структурированный, для сложных фич, упрощённый).  
  Содержит правила git-цикла и формат Conventional Commits.

- **Git_Mini_Guide.md**  
  Мини-шпаргалка по Git (инициализация, базовый цикл, просмотр истории, работа с ветками, отмена изменений).  
  Фокус на использовании в macOS Terminal.



## 18. Release History & Milestones

### Последние релизы
- **v1.15.0 (2025-10-13)** – Liquid Glass TabBar update (iOS 18+), внедрение `CustomTabBarView` с поддержкой fallback blur.  
- **v1.14.0 (2025-10-12)** – ArticleRenderer интегрирован в UIUtils; новые визуальные утилиты и компоненты статей.  
- **v1.13.5 (2025-10-07)** – стабильное обновление после DI-рефакторинга.  

### Milestones
- **v1.15.0-architecture-milestone** – закрепление новой архитектуры (MVVM + Repositories + строгий DI).  
- **v1.14.0-localization-complete** – завершена полная мультиязычная поддержка (7 языков).  

### Важные изменения
- 📱 **UI/UX**: переход от системного TabBar к кастомному стеклянному стилю.  
- 🧩 **Статьи**: добавлен ArticleRenderer и новые блоки (цитаты, чеклисты, FAQ).  
- 📊 **Менеджеры**: удалены устаревшие `ReadingHistoryManager`, `ReadingTimeTracker`, `ReadingProgressTracker`; добавлен `ReadingStatsManager` с моделями `ReadingHistoryEntry` и `ReadingStats`.  
- 📝 **Документация**: регулярные обновления `Docs/project_tree.md` и `AI_CONTEXT.md`.  

### Активные ветки разработки
- `feature/liquid-glass-tabbar`, `feature/custom-tabbar` – развитие кастомного таббара.  
- `feat/article-renderer-uiutils-integration` – интеграция ArticleRenderer.  
- `continue-di-refactoring`, `fix/ui-di-violations` – рефакторинг DI.  
- `fix/caching-strategy-unification` – унификация стратегии кэширования.  
- `tests/*` – работа над тестами (unit, categorymanager).  
- `refactor/*` – переводы отдельных модулей на MVVM.  


---

## 19. Roadmap / Next Steps

### Текущий прогресс
- ✅ Core Layer (AppContainer, ContentView, InGermanyApp)  
- ✅ Managers Layer (9 менеджеров, устаревшие `ReadingHistoryManager`, `ReadingTimeTracker`, `ReadingProgressTracker` удалены; добавлен `ReadingStatsManager`)  
- ✅ Models Layer (6 моделей, включая `ReadingStats` и `ReadingHistoryEntry`)  
- ✅ Protocols Layer (9/10 протоколов, `FavoritesManaging` пустой)  
- ✅ Services Layer (12 сервисов, включая DataService, NetworkService, LocalizationManager, ExportToPDF, ArticleRenderer, TextAnalysisService)  
- ✅ Repositories Layer (ArticlesRepositoryImpl)  
- ✅ ViewModels Layer (12 VM, включая Home, Settings, ArticleDetail, Search)  
- ✅ Views Layer (экраны, секции, компоненты, ArticleRenderer UI)  
- ✅ UIUtils Layer (частично: CustomTabBarView, ArticleBlockView, ChecklistCardView, FAQBlockView; новые блоки — Liquid Glass TabBar)  

### Следующие шаги

4. 🔧 **FavoritesManagingProtocol** — дополнить интерфейс, чтобы унифицировать работу с избранным и исключить "пустой" протокол.  
5. 🧩 **Localization** — проверить наличие всех новых ключей (`ArticleBlockView`, `ChecklistCardView`, `FAQBlockView`, CustomTabBarView и др.) в `Localizable.xcstrings`.  
6. 📊 **Документация** — продолжать вести `CHANGELOG.md` и `AI_CONTEXT.md` синхронно с кодом; использовать milestone-теги (`architecture-milestone`, `localization-complete`) как маркеры больших этапов.  
7. ✅ **CI/CD** — рассмотреть внедрение GitHub Actions для автоматической проверки DI-нарушений, линтинга (SwiftLint) и прогонки тестов.  
8. 🚀 **Будущие фичи**:
   - Авторизация (реализация `AuthService`, пока TODO).  
   - Расширение статистики чтения (графики, streak, история по дням).  
   - Интеграция Firebase или Supabase (синхронизация и облачное хранение).  
   - UI-улучшения: плавные анимации ( Shimmer-loading), расширение ArticleRenderer (списки, ссылки, изображения).  
   


---

## 📄 Документация редактора статей (Article Editor / Mini-CMS)

В проекте реализован **Article Editor**, превращающий приложение InGermany в мини-CMS для создания и редактирования статей.

- **Основной roadmap и инструкция для AI-агентов**:  
  [Docs/ARTICLE_EDITOR_ROADMAP.md](Docs/ARTICLE_EDITOR_ROADMAP.md)

### Ключевые возможности
- Создание и редактирование статей с заголовком и блоками (paragraph, info, warning, tip, quote, list, checklist, faq, links).  
- Live Preview через `ArticleRenderer`.  
- Экспорт JSON в файл `Documents/article.json`.  
- Поддержка сериализации `{ title, blocks }`.  
- Подготовка к будущим шагам: импорт JSON, библиотека статей, дублирование блоков, MacOS Admin App.  

### Ключевые файлы
- `Shared/Models/ArticleBlock.swift`  
- `Shared/ViewModels/ArticleEditorViewModel.swift`  
- `Views/Editor/ArticleEditorView.swift`  
- `Views/Editor/BlockPickerView.swift`  
- `Services/ArticleRenderer.swift`  

