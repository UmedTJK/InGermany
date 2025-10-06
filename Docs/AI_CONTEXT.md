```markdown
AI_CONTEXT.md

Единый контекст для ИИ-агентов. Задача — обеспечить моментальное понимание проекта и выпуск **релевантного, безопасного и соответствующего стандартам** кода. Документ публикуется в репозитории и прикладывается ко всем запросам к ИИ-агентам.

---

## 0) Мета

* **Проект:** InGermany (iOS, SwiftUI, iOS 17+)  
* **Репозиторий:** [https://github.com/UmedTJK/InGermany](https://github.com/UmedTJK/InGermany)  
* **Локальный путь:** `~/Desktop/InGermany`  
* **Ветка по умолчанию:** `main` (активная может быть фича-ветка, см. `Docs/git_snapshot.md`)  
* **CI/Lint:** SwiftLint (локально), Xcode build  
**Поддерживаемые языки контента:**  
`ru / en / de / tj / fa / ar / uk`  

- `ru` — Русский  
- `en` — English  
- `de` — Deutsch  
- `tj` — Тоҷикӣ  
- `fa` — فارسی (фарси)  
- `ar` — العربية (арабский, RTL)  
- `uk` — Українська  
 
* **Цель:** showcase-приложение для портфолио (App Store-стиль UI), офлайн-first + обновление данных из GitHub Pages  

---

## 1) Принципы

1. **Безопасность и надёжность прежде фич.**  
2. **Прозрачная актуальность**: сверка `git status` и структуры проекта.  
3. **Один шаг = один коммит** (Conventional Commits).  
4. **Строгие контракты данных** (§2b/2c).  
5. **Concurrency-чистота** (Swift 6 Ready, MainActor isolation).  
6. **UI = Apple HIG.**  
7. **Документируемое изменение.**
8. **Полное тестовое покрытие** всех публичных API.
9. **Dependency Injection** через AppContainer.
10. **MVVM архитектура** с тонкими Views.

---

## 2) Архитектура и структура проекта

* **Core/**: `InGermanyApp.swift`, `ContentView.swift`, `AppContainer.swift`  
* **Models/**: `Article.swift`, `Category.swift`, `Location.swift`  
* **Services/**:  
  - `DataService.swift`  
  - `NetworkService.swift`  
  - `ShareService.swift`  
  - `AuthService.swift`  
  - `DefaultsStore.swift`  
  - `ExportToPDF.swift`  
  - `LocalizationManager.swift`  
  - `ArticlesRepositoryImpl.swift`  
* **Managers/**:  
  - `FavoritesManager.swift`  
  - `RatingManager.swift`  
  - `ReadingHistoryManager.swift`  
  - `ReadingTimeTracker.swift`  
  - `TextSizeManager.swift`  
  - `ReadingProgressHelper.swift`  
  - `ReadingProgressTracker.swift`  
  - `ReadingTimeCalculator.swift`  
  - `CategoryManager.swift`  
* **Protocols/**:  
  - `ArticlesRepositoryProtocol.swift`  
  - `CategoriesRepositoryProtocol.swift` 
  - `FavoritesManagingProtocol.swift`

* **UIUtils/**:  
  - `Theme.swift`  
  - `Animations.swift`  
  - `CardSize.swift`  
  - `Color+Hex.swift`  
  - `ProgressBar.swift`  
  - `CardImageStyle.swift`  
* **Formatters/**:  
  - `DateFormatter+Localized.swift`  
  - `ReadingTimeFormatter.swift`  
  - (другие форматтеры для дат, времени, текста)  
* **ViewModels/**: 
  - `AboutViewModel.swift`
  - `ArticleDetailViewModel.swift`
  - `ArticleRowViewModel.swift`
  - `CategoriesViewModel.swift`
  - `FavoritesViewModel.swift`
  - `HomeViewModel.swift`
  - `SearchViewModel.swift`
  - `SettingsViewModel.swift`
  - `ViewModels.swift` (namespace)
* **Views/**: `HomeView`, `SearchView`, `FavoritesView`, `CategoriesView`, `ArticlesByCategoryView`, `ArticlesByTagView`, `ArticleDetailView`, `SettingsView`, `AboutView`, `MapView`  

  - **HomeView.swift** — оболочка для главного экрана: отвечает за загрузку/обновление данных и навигацию. 
  - **Sections/** — новые компоненты для секций главного экрана:
    - `UsefulToolsSection.swift` — блок «Полезные инструменты».
    - `RecentlyReadSection.swift` — блок «Недавно прочитанное».
    - `FavoritesSection.swift` — блок «Избранное».
    - `CategorySection.swift` — горизонтальные ленты статей по категориям.
    - `AllArticlesSection.swift` — блок со всеми статьями.
> Начиная с v1.8.7, `HomeView` больше не содержит внутреннюю разметку секций. Все UI-блоки вынесены в отдельные вью для упрощения сопровождения и работы ИИ-агентов.

* **Views/Components/**: `ArticleCardView`, `ArticleRow`, `ArticleMetaView`, `ArticleCompactCard`, `FavoriteCard`, `RecentArticleCard`, `ToolCard`, `EmptyFavoritesView`, `CategoryFilterButton`, `TagFilterView`, `TextSizeSettingsPanel`, `ReadingProgressBar`, `ReadingProgressView`, `CircularReadingProgress`, `PDFViewer`, `StarRatingView`, `LanguagePickerView`  
* **Views/Cards/**: `ArticleCompactCard.swift`  
* **Resources/**: `articles.json`, `categories.json`, `locations.json`  
* **Docs/**: `AI_CONTEXT.md`, `CHANGELOG.md`, `PROMPTS_FOR_AI_AGENTS.md`, `Git_Mini_Guide.md`, `CLEAN_CODE_CHECKLIST.md`, `git_snapshot.md`, `project_tree.md`, `locations_README.md`, `hooks/pre-push.template`  
* **Scripts/**: `update_project_tree.sh`, `update.sh`  
* **Tests/**: `InGermanyTests/` (21 компонентов, 262 теста)  
* **Корень**: `.swiftlint.yml`, `README.md`, `update.sh`, `HomeView_Context.zip`, `project_structure.txt`, `temp_ai_context.md`

### Dependency Injection и AppContainer (с версии v1.10.0)

Для управления зависимостями используется `AppContainer` (Composition Root), помеченный `@MainActor`.  
AppContainer создаёт экземпляры ViewModel и менеджеров, централизуя конфигурацию приложения.

- **AppContainer** (`AppContainer.swift`)
  - `articlesRepo: ArticlesRepository` → реализован через `ArticlesRepositoryImpl`
  - `categoriesRepo: CategoriesRepository` → `DefaultCategoriesRepository.shared`
  - `favoritesManager: FavoritesManager` → singleton `.shared`
  - `historyManager: ReadingHistoryManager` → singleton `.shared`
  
  **Фабричные методы:**
  - `makeHomeViewModel()` → возвращает `HomeViewModel`
  - `makeSearchViewModel()` → возвращает `SearchViewModel`
  - `makeCategoriesViewModel()` → возвращает `CategoriesViewModel` (⚠️ создает зависимости напрямую)
  - `makeSettingsViewModel()` → возвращает `SettingsViewModel`
  - `makeArticleDetailViewModel(article:allArticles:)` → возвращает `ArticleDetailViewModel`
  - `makeAboutViewModel()` → возвращает `AboutViewModel`
  - `makeFavoritesViewModel()` → возвращает `FavoritesViewModel`

### ViewModels (MVVM Architecture)

- **HomeViewModel**
  - **MainActor, ObservableObject:** Класс помечен `@MainActor` и реализует `ObservableObject` для корректной работы с состоянием и интеграции с SwiftUI.
  - **Ответственность:** Управление данными главного экрана
  - **Зависимости:** `ArticlesRepository`, `FavoritesManager`, `ReadingHistoryManager`, `CategoriesRepository`
  - **Состояния:** 
    - `articles`
    - `isLoading`
    - `dataSource` — по умолчанию `"unknown"`, обновляется в `loadData()` и `refreshData()` через `articlesRepo.getLastSource()`
    - `isShowingRandomArticle`
    - `randomArticle`
  - **Методы:** `loadData()`, `refreshData()`, `selectRandomArticle()`
  - **Вычисляемые свойства:** `allCategories`, `articlesByCategory`
  - **Особенности:** 
    - Имеет `convenience init()`, который использует `FavoritesManager.shared`, `ReadingHistoryManager.shared`, `DefaultCategoriesRepository.shared` и `ArticlesRepositoryImpl()` для обратной совместимости.

- **FavoritesViewModel**
  - **Ответственность:** Управление списком избранного
  - **MainActor, ObservableObject:** класс помечен `@MainActor`, реализует `ObservableObject`.
  - **Зависимости:** `FavoritesManager`, `ArticlesRepository`
  - **Состояния:** 
    - `allArticles` — список всех статей  
    - `favoriteArticles` — список избранных статей  
    - `isLoading` — индикатор загрузки  
    - `dataSource` — источник данных; по умолчанию `"unknown"`, обновляется в `loadFavorites()` через `articlesRepo.getLastSource()`  
  - **Методы:**  
    - `loadFavorites()` — загружает все статьи, фильтрует избранные, обновляет `dataSource`  
    - `toggleFavorite(for:)` — переключает статус избранного и обновляет список избранных статей
    
- **SearchViewModel**
  - **MainActor, ObservableObject:** Класс помечен `@MainActor` и реализует `ObservableObject` для корректной работы с состоянием и интеграции с SwiftUI.
  - **Ответственность:** Управление логикой поиска и фильтрации
  - **Зависимости:** `FavoritesManager`, `CategoriesRepository`, `ArticlesRepository`
  - **Состояния:**
    - `articles`
    - `searchText`
    - `selectedTag`
    - `isLoading`
    - `dataSource` — по умолчанию `"unknown"`, обновляется в `loadArticles()` через `articlesRepo.getLastSource()`
  - **Вычисляемые свойства:** 
    - `filteredArticles` — фильтрация происходит по тегам, тексту, а также по локализованному названию категории через `categoriesRepo`
    - `allTags`
  - **Методы:** `loadArticles()`
  - **Особенности:** Использует `@AppStorage("selectedLanguage")` для локализации поиска, имеет `convenience init()`

- **CategoriesViewModel**
  - **Ответственность:** Управление загрузкой категорий и связанных статей
  - **MainActor, final, ObservableObject:** класс помечен `@MainActor`, является `final` и реализует `ObservableObject`.
  - **Зависимости:** `CategoriesRepository`, `ArticlesRepository`, `FavoritesManager`
  - **Состояния:** `categories`, `articles`
  - **Методы:** 
    - `load()` — вызывает `categoriesRepo.bootstrap()` и загружает статьи через `articlesRepo.loadArticles()`
    - `refresh()` — вызывает `categoriesRepo.refresh()` и загружает статьи через `articlesRepo.refreshArticles()`
    - `category(by:)`
    - `articles(for:)`
    - `loadData()` (для обратной совместимости, вызывает `refresh()`)
  - **Особенности:** Опциональный `favoritesManager` в init
  
- **SettingsViewModel**
  - **MainActor, ObservableObject:** Класс помечен `@MainActor` и реализует `ObservableObject` для корректной работы с состоянием и интеграции с SwiftUI.
  - **Ответственность:** Управление настройками и историей чтения
  - **Зависимости:** `ReadingHistoryManager`
  - **Состояния:**
    - `selectedLanguage` — хранится в `@AppStorage("selectedLanguage")`, по умолчанию `"ru"`.
    - `isHistoryCleared` — по умолчанию `false`; устанавливается в `true` после вызова `clearHistory()`.
  - **Методы:** `clearHistory()`, `changeLanguage(to:)`, `getStats()` → возвращает `ReadingStats`

- **ArticleDetailViewModel**
  - **Ответственность:** Управление состоянием экрана статьи
  - **Зависимости:** `FavoritesManager`, `ReadingHistoryManager`
  - **Состояния:** `article`, `allArticles`, `isFavorite`
    - **Примечание:** `isFavorite` инициализируется в `init` на основе `FavoritesManager.isFavorite(article.id)`.
  - **Методы:** 
    - `toggleFavorite()`
    - `exportToPDF()` — экспортирует статью в PDF, имя файла берётся из `article.pdfFileName ?? article.id`.
    - `markAsRead()`
  - **Особенности:** Жестко закодирован язык "ru" в PDF экспорте

- **ArticleRowViewModel**
  - **Ответственность:** Управление отображением строки статьи
  - **Зависимости:** `FavoritesManager`, `RatingManager`
  - **Состояния:** `isFavorite`, `rating`, `imageName`
  - **Инициализация:** 
    - Основной `init(article:favoritesManager:ratingManager:)` (Dependency Injection).
    - Упрощённый `convenience init(article:)` использует глобальные `shared` менеджеры.
  - **Методы:** `toggleFavorite()`, `setRating(_:)`
  - **Вычисляемые свойства:** 
    - `title` → основан на `Article.localizedTitle(for:)` (жёстко "ru")
    - `subtitle` → основан на `Article.formattedReadingTime(for:)` (жёстко "ru")
    - `metaInfo` → объединяет `Article.formattedCreatedDate(for:)` и `Article.formattedUpdatedDate(for:)` (жёстко "ru")
  - **Особенности:** Имеет `convenience init(article:)` для упрощенного создания

- **AboutViewModel**
  - **Ответственность:** Управление экраном «О приложении»
  - **MainActor, ObservableObject:** Класс помечен `@MainActor` и реализует `ObservableObject` для корректной работы с состоянием и интеграции с SwiftUI.
  - **Состояния:** `appVersion`, `buildNumber`, `repositoryURL`
    - **repositoryURL:** Свойство `repositoryURL` инициализируется значением `"https://github.com/UmedTJK/InGermany"`.
  - **Методы:** автоматическая загрузка информации из Bundle

### Views и их ViewModels

- **HomeView** → `HomeViewModel` (из `AppContainer.makeHomeViewModel()`)
- **FavoritesView** → `FavoritesViewModel` (из `AppContainer.makeFavoritesViewModel()`)
- **SearchView** → `SearchViewModel` (из `AppContainer.makeSearchViewModel()`)
- **CategoriesView** → `CategoriesViewModel` (из `AppContainer.makeCategoriesViewModel()`)
- **SettingsView** → `SettingsViewModel` (из `AppContainer.makeSettingsViewModel()`)
- **ArticleDetailView** → `ArticleDetailViewModel` (из `AppContainer.makeArticleDetailViewModel()`)
- **AboutView** → `AboutViewModel` (из `AppContainer.makeAboutViewModel()`)
- **ArticleRow** → `ArticleRowViewModel` (создается напрямую)

---

## 2a) Структура проекта (актуальная)

Полное дерево проекта хранится в файле: `Docs/project_tree.md`

> ⚠️ Обновляется автоматически через скрипт:
> ```bash
> ./scripts/update_project_tree.sh 3
> ```
> Или вручную:
> ```bash
> cd ~/Desktop/InGermany
> tree -L 3 > Docs/project_tree.md
> ```

---

## 2b) Потоки данных, менеджеры и хранение (Дата актуализации: 06.10.2025)

### Модели

- **Article**  
  `id: String`, `title: [String: String]`, `content: [String: String]`, `categoryId: String`, `tags: [String]`, `pdfFileName: String?`, `createdAt: String?`, `updatedAt: String?`, `image: String?`  
  **Кастомное Codable:** Обработка строковых дат в ISO8601 формате для обратной совместимости  
  **Полная локализация:** Поддерживает все 7 языков (`ru`, `en`, `de`, `tj`, `fa`, `ar`, `uk`) в title и content  
  **Markdown-контент:** Поле content содержит текст с Markdown-разметкой  
  **JSON Mapping:** Поля модели напрямую соответствуют полям в `articles.json`  
  **Методы:**  
    - `localizedTitle(for:)` → с фолбэком на "en" или первое значение
    - `localizedContent(for:)` → с фолбэком на "en" или первое значение  
    - `formattedCreatedDate(for:)` → средний формат даты с локализацией
    - `formattedUpdatedDate(for:)` → средний формат даты с локализацией  
    - `relativeCreatedDate(for:)` → относительный формат ("3 дня назад")
    - `readingTime(for:)` → время чтения для конкретного языка
    - `formattedReadingTime(for:)` → форматированное время чтения
    - `imageName` → нормализация имени изображения: конвертация `.avif` в `.jpg`, добавление расширения при отсутствии  
    - `wordCount` → подсчитывается через `ReadingTimeCalculator.estimateReadingTime() * 200` (НЕ прямой подсчет слов)
    - `isNew` → создана в последние 7 дней
    - `isUpdatedRecently` → обновлена в последние 3 дня
    - `getTranslation(key:language:)` (приватный) → хардкод-словари для фраз "Дата неизвестна", "Не обновлялась"
  
  **Особенности:**
  - Использует `ISO8601DateFormatter()` для кодирования/декодирования дат
  - Жестко закодированные локали для форматирования: ru_RU, en_US, de_DE, tj → ru_RU
  - Hashable реализация основана только на `id`
  - Sample данные включают изображения и даты
  - Поле `image` содержит только имя файла без пути (например, "germany2.jpg")

- **Category**  
  `id: String`, `name: [String: String]`, `icon: String (SF Symbol)`, `colorHex: String`  
  **JSON Mapping:** Поля модели напрямую соответствуют полям в `categories.json`  
  **Метод:** `localizedName(for:)` → фолбэк на "en" или первое доступное значение  
  **Поддерживаемые языки:** Модель ожидает переводы только для `ru`, `en`, `de`, `tj`  
  **Особенности:** Имеет поле `colorHex` для цветового оформления

- **Location**  
  `id: String`, `name: String`, `latitude: Double`, `longitude: Double`  
  **JSON Mapping:** Поля модели напрямую соответствуют полям в `locations.json`  
  **Свойство:** `coordinate: CLLocationCoordinate2D` → вычисляемое свойство для MapKit  
  **Особенности:** Простая модель без методов локализации, имя только на немецком/русском

### Менеджеры состояния (Дата актуализации: 06.10.2025)

- **FavoritesManager** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** `DefaultsStore` → ключ "favorites", массив `[String]` (конвертируется в `Set<String>`)
  - **Состояние:** `@Published private(set) var favorites: Set<String>`
  - **Методы:** 
    - `isFavorite(_:)` и `isFavorite(id:)` (для обратной совместимости)
    - `toggleFavorite(for:)` 
    - `favoriteArticles(from:)` - фильтрация массива статей
    - `clearForTesting()` - для тестов
  - **Особенности:** Автоматическая загрузка при инициализации

- **RatingManager** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** `UserDefaults` → ключ "articleRatings", словарь `[String: Int]`
  - **Состояние:** `@Published private var ratings: [String: Int]`
  - **Методы:** `getRating(for:) -> Int`, `setRating(_:for:)`, `clearForTesting()`
  - **Особенности:** Поддерживает инъекцию `UserDefaults` через `init(userDefaults:)`

- **ReadingHistoryManager** (`ObservableObject`, НЕ `@MainActor`)
  - **Singleton:** `static let shared`
  - **Хранение:** `@AppStorage("readingHistory") private var storedHistory: Data`
  - **Состояние:** `@Published private(set) var history: [ReadingHistoryEntry]`
  - **Модели:** `ReadingHistoryEntry`, `ReadingTracker`, `ReadingStats`
  - **Методы:** 
    - `addReadingEntry(articleId:readingTime:)`
    - `recentlyReadArticles(from:limit:)` - возвращает до 5 последних статей
    - `isRead(_:)`, `lastReadDate(for:)`, `clearHistory()`, `getStats() -> ReadingStats`
    - `clearForTesting()`
  - **Статистика:** `totalReadingTimeMinutes`, `totalArticlesRead`
  - **Ограничения:** Максимум 100 записей в истории

- **CategoryManager** (`actor`, НЕ `@MainActor`)
  - **⚠️ НЕ ИСПОЛЬЗУЕТСЯ в DI** - существует параллельно с CategoriesRepository
  - **Глобальный инстанс:** `let categoryManager = CategoryManager()` (не singleton)
  - **Зависимости:** `DataService.shared` напрямую
  - **Методы:** `loadCategories() async`, `allCategories()`, `category(for id:)`, `category(for name:language:)`, `refreshCategories() async`
  - **Особенности:** Actor для thread safety, но нарушает DI принципы

- **TextSizeManager** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** `DefaultsStore` → ключи "textSize" (enum) и "customTextScale" (Double)
  - **Состояния:** `@Published private(set) var textSize: TextSize`, `@Published var customScale: Double`
  - **Методы:** `setTextSize(_:)`, автоматическое сохранение при изменении `customScale`
  - **Особенности:** Поддерживает и enum-based и slider-based управление размером текста

- **ReadingProgressTracker** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** память приложения (НЕ сохраняется между запусками)
  - **Состояние:** `@Published private(set) var progress: [String: CGFloat]`
  - **Методы:** `updateProgress(for:value:)`, `progressForArticle(_:)`, `reset(for:)`
  - **Особенности:** Прогресс сбрасывается при перезапуске приложения

- **ReadingTimeTracker** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** `DefaultsStore` → ключ "readingSessions", массив `[ReadingSession]`
  - **Состояния:** `@Published private(set) var activeSessions: [String: ReadingSession]`, `@Published private(set) var completedSessions: [ReadingSession]`
  - **Модель:** `ReadingSession` с `articleId`, `startTime`, `endTime`, `duration`
  - **Методы:** `startSession(articleId:)`, `endSession(articleId:)`, `getTotalReadingTime()`, `getReadingTimeForLast(days:)`
  - **Фильтрация:** Сохраняет только сессии длительнее 3 секунд

- **ReadingTimeCalculator** (struct, НЕ менеджер)
  - **Статические методы:** `estimateReadingTime(for:language:)`, `formatReadingTime(_:language:)`
  - **Скорости чтения:** `ru: 200`, `en: 250`, `de: 220`, `tj: 180` слов/минуту
  - **Минимум:** Всегда возвращает не менее 1 минуты

- **ReadingProgressHelper** (struct, утилита)
  - **Статические методы:** `color(for:)`, `status(for:language:)`, `progressView(progress:language:)`
  - **Цвета прогресса:** green (0-50%), orange (50-80%), red (80-100%)
  - **⚠️ Нарушение DI:** Использует `LocalizationManager.shared` напрямую

### Сервисы (Дата актуализации: 06.10.2025)

- **DataService** (`actor`)
  - **Singleton:** `static let shared`
  - **Зависимости:** `NetworkService.shared`
  - **Кэширование:** `articlesCache`, `categoriesCache`, `locationsCache` в памяти
  - **Стратегия:** Offline-first (память → локальный JSON → сеть асинхронно)
  - **Методы:**
    - `loadArticles() async -> [Article]` - основной метод загрузки
    - `loadCategories() async -> [Category]`
    - `loadLocations() async -> [Location]`
    - `refreshData() async` - принудительное обновление (очищает кэш и перезагружает все данные)
    - `clearCache()` - очистка кэша
    - `getLastDataSource() async -> [String: String]` - возвращает словарь источников данных для каждого типа
  - **Логирование:** Подробные console-логи с префиксами (📦, 📂, 🌐, ⚠️)
  - **Особенности:** Асинхронное обновление из сети после возврата локальных данных, использует `withCheckedContinuation` для локальных fallback

- **NetworkService** (class, НЕ actor)
  - **Singleton:** `static let shared`
  - **База URL:** `https://raw.githubusercontent.com/UmedTJK/InGermany/main/Resources/`
  - **Кэширование:** `URLCache` (10MB память, 50MB диск) + файловая система в `~/Library/Caches/InGermanyCache/`
  - **Стратегия:** **Сеть → файловый кэш → Bundle** (НЕ offline-first!)
  - **Методы:**
    - `loadJSON<T: Decodable>(from:) async throws -> T` - основной async метод
    - `loadJSONSync<T>(from:completion:)` - legacy sync метод
    - `clearCache()` - очистка кэша
  - **Таймаут:** 10 секунд
  - **Особенности:** Подробная обработка ошибок, **игнорирование локального кэша при сетевых запросах** (`cachePolicy = .reloadIgnoringLocalCacheData`)

- **ArticlesRepositoryImpl** (final class)
  - **Реализация:** `ArticlesRepository` protocol
  - **Зависимости:** `DataService.shared` напрямую
  - **Методы:**
    - `loadArticles() async -> [Article]` → делегирует `DataService.shared.loadArticles()`
    - `refreshArticles() async -> [Article]` → вызывает `DataService.shared.refreshData()` и затем `DataService.shared.loadArticles()`
    - `getLastSource() async -> String` → получает источник из `DataService.shared.getLastDataSource()["articles"]` с фолбэком "unknown"
  - **Особенности:** Тонкая прокладка без дополнительной логики, адаптер для DataService

- **LocalizationManager** (`@MainActor`, `final`, `ObservableObject`)
  - **Singleton:** `static let shared`
  - **Хранение:** `@AppStorage("selectedLanguage") var selectedLanguage: String = "ru"`
  - **Методы:**
    - `getTranslation(key:language:) -> String` - основной метод с жестко закодированным словарем
    - `t(_:language:) -> String` - сокращенный метод с автоопределением языка
  - **Словарь:** **Полный жестко закодированный словарь** переводов для всех 7 языков (200+ ключей)
  - **Расширения:** `View.t(_:)` для удобного доступа в SwiftUI
  - **Особенности:** Полная поддержка всех языков проекта, **не использует внешние файлы локализации**

- **ShareService** (class)
  - **Статические методы:** `shareArticle(_:language:)`
  - **Форматирование:** Заголовок + контент + подпись "Читайте в приложении InGermany!"
  - **Платформа:** Использует `UIActivityViewController` для iOS share sheet
  - **Язык:** По умолчанию русский

- **ExportToPDF** (struct)
  - **Статические методы:** `export(title:content:fileName:)`
  - **Формат:** A4 (595.2 × 841.8 points) с полями 20pt
  - **Метаданные:** Creator, Author, Title
  - **Шрифты:** Bold 24pt для заголовка, Regular 16pt для контента
  - **Сохранение:** В папку Documents с именем `fileName.pdf`
  - **Логирование:** Успех/ошибка в console

- **DefaultsStore** (enum)
  - **Статические методы:** `load<T: Codable>(_ key:as:) -> T?`, `save<T: Codable>(_ value:for:)`
  - **Реализация:** JSON encoding/decoding поверх `UserDefaults`
  - **Особенности:** Универсальный helper для Codable объектов, используется FavoritesManager и другими компонентами

- **AuthService** (class)
  - **⚠️ ПОЛНАЯ ЗАГЛУШКА:** Только TODO комментарии, функциональность не реализована
  - **Планируемая ответственность:** Аутентификация, управление сессиями, хранение токенов
  - **Текущий статус:** Класс существует но не содержит никакой реализации

### UI-компоненты и утилиты (Дата актуализации: 06.10.2025)

- **Animations.swift** — расширенный набор анимаций и стилей:
  - **View Modifiers:** `cardStyle()`, `lightCardStyle()`, `scaleOnAppear()`, `pressAnimation()`, `slideInAnimation(delay:)`
  - **Button Styles:** `AppleCardButtonStyle`, `ScaleButtonStyle` (кастомизируемый масштаб)
  - **Loading States:** `LoadingView` — индикатор загрузки с тремя анимированными точками
  - **Shimmer Effect:** `ShimmerModifier` и метод `.shimmer()` для эффекта мерцания
  - **Transition Effects:** `.slideAndFade`, `.scaleAndFade` — готовые переходы
  - **Haptic Feedback:** `HapticFeedback` с методами `light()`, `medium()`, `heavy()`, `success()`, `error()`, `warning()`

- **Theme.swift** — темы и стили:
  - **Цвета:** `primaryBlue`, `secondaryGray`, `backgroundCard`, `backgroundMain`
  - **Градиенты:** `cardGradient`, `favoriteCardGradient` 
  - **Отступы:** `cardPadding`, `smallPadding`, `mediumPadding`, `largePadding`
  - **Тени:** `cardShadow`, `lightShadow` (структура `Shadow`)
  - **Методы:** `sectionCardStyle()` для секций с вертикальными отступами
  - **Особенности:** Имеет дублирующую функциональность с `Animations.cardStyle()`

- **CardImageStyle.swift** — стили изображений в карточках:
  - `allCorners`, `bottomCorners`, `fullWidth`
  - **⚠️ Прямое использование** `LocalizationManager.shared` без DI

- **Color+Hex.swift** — расширение Color для работы с HEX
  - `init?(hex: String)` — создание из HEX строки

- **ProgressBar.swift** — компонент прогресс-бара
  - **⚠️ Жестко закодированные цвета** (.gray, .blue) вместо Theme
  - Фиксированная высота 4pt
  - Анимация продолжительностью 0.3 секунды
  - Простая реализация без кастомизации цветов или высоты

- **CardSize.swift** — утилита для расчета размеров карточек:
  - `width(for:)` — расчет ширины на основе ширины экрана
  - `height(for:screenWidth:)` — расчет высоты на основе размеров экрана
  - Поддерживает адаптацию для iPhone SE, обычных iPhone и iPad

- **TextSizeSettingsPanel** — экран настройки текста.  
- **TagFilterView** — фильтр тегов.  
- **ReadingProgressBar / ReadingProgressView / CircularReadingProgress** — прогресс чтения.  
- **PDFViewer** — рендер PDF из Bundle.  
- **FavoriteCard** — карточка избранного.  
- **Components.swift**: `ToolCard`, `RecentArticleCard`, `EmptyFavoritesView`, `CategoryFilterButton`.  
- **ArticleCardView** — карточка статьи в сетке.  
- **ArticleMetaView** — категория, даты, бейджи.  
- **ArticleRow** — строка списка статей, работает через `ArticleRowViewModel` (MVVM).
- **ArticleCompactCard** — компактная карточка статьи, используемая в списках и секциях.
- **ReadingProgressHelper** — утилита для прогресса чтения (цвета, статусы).

---

## 2c) Публичные интерфейсы

#### Управление размером текста
- Ранее выбор осуществлялся через enum `TextSize` (small/medium/large).  
- Начиная с v1.9.0 управление перенесено на `Slider` с диапазоном **0.8 ... 1.5** (80%–150%).  
- Новое поле `TextSizeManager.customScale: Double` хранит текущее значение масштаба и сохраняется в `DefaultsStorage`.  
- Enum `TextSize` по-прежнему используется для функции «Сбросить» и обратной совместимости.  
- `ArticleDetailView` и все текстовые представления теперь используют `customScale` вместо жёсткой привязки к `TextSize.scale`.

#### Настройки интерфейса (AppStorage)
- `selectedLanguage: String` — выбранный язык интерфейса
- `cardImageStyle: CardImageStyle` — стиль изображений в карточках
- `isDarkMode: Bool` — темная тема
- `relativeDates: Bool` — относительный формат дат

---

## 3) Ресурсы

### **articles.json** — содержит массив статей со структурой:
```json
{
  "id": "UUID-строка",
  "title": {
    "ru": "строка", "en": "строка", "de": "строка", 
    "tj": "строка", "fa": "строка", "ar": "строка", "uk": "строка"
  },
  "content": {
    "ru": "Markdown-контент", "en": "Markdown-контент", ...
  },
  "categoryId": "UUID-строка",
  "tags": ["массив", "строк"],
  "createdAt": "ISO8601-дата",
  "updatedAt": "ISO8601-дата", 
  "image": "имя-файла.jpg",
  "pdfFileName": "опционально-имя-PDF-файла"
}
```
**Особенности:**
- **Полная локализация:** Все 7 языков поддерживаются в title и content
- **Markdown-контент:** Содержимое использует Markdown-разметку
- **Изображения:** Поле `image` содержит имя файла без пути
- **Даты:** Строковые даты в формате ISO8601 (`2025-09-20T10:00:00Z`)

### **categories.json** — содержит массив категорий:
```json
{
  "id": "UUID-строка", 
  "name": {
    "ru": "строка", "en": "строка", "de": "строка", "tj": "строка"
  },
  "icon": "SF Symbol name",
  "colorHex": "HEX-код цвета"
}
```
**Особенности:** Поддерживает только 4 языка (`ru`, `en`, `de`, `tj`)

### **locations.json** — содержит массив локаций:
```json
{
  "id": "строка",
  "name": "строка (без локализации)",
  "latitude": число,
  "longitude": число
}
```
**Особенности:** Простая структура без локализации названий

- `Resources/Images/` — изображения статей в локализованных папках .lproj
- `Assets.xcassets` (логотипы, иконки)  
- `Docs/*` (AI_CONTEXT, project_tree, git_snapshot и др.)  
- `scripts/` — скрипты автоматизации
- `update.sh`

---

## 4) Дорожная карта

См. Roadmap в `README.md` и `CHANGELOG.md`.  
Основные направления: улучшение UI, поддержка сетевой загрузки, расширение контента.

---

## 5) Рабочий цикл ИИ-агента

```bash
cd ~/Desktop/InGermany
swiftlint lint --strict || true
git status
git log --oneline --graph -n 10
```

- Если есть незакоммиченные правки → спросить решение.  
- Коммиты только в стиле **Conventional Commits**.  
- Пуш всегда в GitHub.  

**Automation:**
- Скрипт `scripts/update_project_tree.sh` автоматически обновляет структуру проекта
- Git hook `Docs/hooks/pre-push.template` можно установить для автоматического обновления документации

Актуальный снимок git хранится в: `Docs/git_snapshot.md`.

R

- Скрипт scripts/release.sh автоматически генерирует CHANGELOG и создает теги релиза

   Все коммиты должны следовать Conventional Commits для корректной работы

   Теги создаются в формате vX.Y.Z-YYYYMMDD
---

## 6) Unit Tests (XCTest) - ПОЛНОЕ ПОКРЫТИЕ 🎉

### ✅ ТЕКУЩИЙ СТАТУС: 21/21 КОМПОНЕНТОВ, 262 ТЕСТА

**Models (72 теста):**
- ✅ **ArticleTests** — полное покрытие модели статьи (26 тестов)
  - Тестирование кастомного Codable с строковыми датами
  - Локализация заголовков и контента с фолбэками
  - Форматирование дат (medium style и relative)
  - Вычисление времени чтения и wordCount
  - Логика imageName (AVIF→JPG конвертация)
  - Свойства isNew и isUpdatedRecently
  - Hashable реализация на основе id
- ✅ **CategoryTests** — полное покрытие модели категории (24 теста)  
  - Локализация имен с фолбэками
  - Поддержка colorHex
  - SF Symbols иконки
- ✅ **LocationTests** — полное покрытие модели локации (22 теста)
  - Координаты CLLocationCoordinate2D
  - Простая Codable структура

**ViewModels (полное покрытие):**
- ✅ **AboutViewModelTests**
- ✅ **ArticleDetailViewModelTests** — управление избранным, историей чтения, логика связанных статей
- ✅ **ArticleRowViewModelTests** — управление состоянием строки статьи
- ✅ **CategoriesViewModelTests** — загрузка категорий и связанных статей
- ✅ **FavoritesViewModelTests** — комплексное тестирование ViewModel избранного
- ✅ **HomeViewModelTests** — загрузка данных, обновления, выбор случайной статьи
- ✅ **SearchViewModelTests** — фильтрация по тексту, тегам, категориям
- ✅ **SettingsViewModelTests** — смена языка, очистка истории, настройки

**Managers (комплексное тестирование):**
- ✅ **FavoritesManagerTests** — добавление/удаление избранного, фильтрация статей, тестирование `clearForTesting()`
- ✅ **RatingManagerTests** — установка и получение рейтинга, очистка для тестов
- ✅ **ReadingHistoryManagerTests** — добавление/очистка истории, ограничение в 100 записей, статистика, `ReadingStats` вычисления
- ✅ **CategoryManagerTests** — загрузка категорий, поиск по ID/имени, обновление данных (actor-тестирование)
- ✅ **ReadingTimeTrackerTests** — управление сессиями, фильтрация коротких сессий (<3 сек), статистика по времени
- ✅ **TextSizeManagerTests** — переключение размеров текста, работа с customScale
- ✅ **ReadingProgressTrackerTests** — отслеживание прогресса чтения, сброс прогресса

**Services (интеграционное тестирование):**
- ✅ **DataServiceTests** — корректная работа с JSON (articles, categories), edge-кейсы: пустые/битые данные, стратегия offline-first
- ✅ **ArticlesRepositoryImplTests** — тестирование репозитория статей, делегирование к DataService
- ✅ **NetworkServiceTests** — загрузка из сети, кэширование, fallback на локальные файлы
- ✅ **LocalizationManagerTests** — переводы для всех языков, фолбэки, работа с AppStorage

**Helpers (115+ тестов):**
- ✅ **ReadingTimeCalculatorTests** — вычисление времени чтения (60+ тестов)
- ✅ **ReadingTimeTrackerTests** — трекинг времени чтения (30+ тестов)
- ✅ **ReadingProgressTrackerTests** — отслеживание прогресса чтения (25 тестов)

**Smoke Tests:**
- ✅ **InGermanyTests** — smoke-тесты инициализации приложения

### Архитектура тестирования
- **Swift 6 Ready**: Full MainActor isolation и concurrency safety
- **Performance Optimized**: Performance tests для всех критических операций
- **Multilingual Support**: Тестирование для всех 7 поддерживаемых языков
- **Real Data Integration**: Тесты используют актуальные JSON данные из ресурсов проекта
- **100% Public API Coverage** для всех компонентов
- **Edge Case Handling** для всех возможных сценариев

---

## 7) Актуальные проблемы архитектуры (Дата актуализации: 06.10.2025)

### 🔴 Критические расхождения

1. **Систематическое нарушение DI в UI компонентах**
   - `ArticleCompactCard`: создает `RatingManager.shared`, `ReadingProgressTracker.shared`, `DefaultCategoriesRepository.shared` напрямую
   - `ArticleMetaView`: создает `RatingManager.shared`, `ReadingHistoryManager.shared`, `DefaultCategoriesRepository.shared` напрямую
   - `ArticleCardView`: создает `RatingManager.shared` напрямую
   - `TextSizeSettingsPanel`: создает `TextSizeManager.shared` напрямую
   - `ArticleDetailView`: создает 4 менеджера напрямую (`ReadingProgressTracker`, `TextSizeManager`, `RatingManager`, `ReadingTimeTracker`)

2. **Прямое использование LocalizationManager в View**
   - `HomeView`, `SearchView`, `AboutView`, `ArticleDetailView`, `CategoriesView`, `MapView`, `PDFViewer`, `ReadingProgressBar`, `TextSizeSettingsPanel` используют `LocalizationManager.shared` напрямую
   - Нарушение DI принципов, должно быть инжектировано через ViewModel

3. **Нарушение DI в ContentView.swift**
   - Создает `FavoritesManager.shared` напрямую через `@StateObject`
   - Использует `DataService.shared` напрямую вместо репозиториев
   - Не использует AppContainer для создания View

4. **Прямые зависимости в MapView**
   - Использует `DataService.shared.loadLocations()` напрямую вместо репозиториев
   - Создает `LocationManager` напрямую через `@StateObject`

5. **Нарушение DI в навигационных View**
   - `ArticlesByCategoryView`, `ArticlesByTagView` принимают `FavoritesManager` напрямую
   - `CategoriesView` передает `FavoritesManager.shared` в дочерние View

6. **Дублирование управления категориями**
   - `CategoryManager` (actor) существует но не используется
   - `DefaultCategoriesRepository` используется вместо него
   - Два разных подхода к одной задаче

7. **AppContainer.makeCategoriesViewModel()**
   - Создает `ArticlesRepositoryImpl()` и `DefaultCategoriesRepository.shared` напрямую
   - Не использует инжектированные `articlesRepo` и `categoriesRepo`

8. **InGermanyApp.swift нарушает DI**
   - Создает `DefaultCategoriesRepository.shared` напрямую через `@StateObject`

9. **Прямые зависимости в UIUtils**
   - `CardImageStyle` использует `LocalizationManager.shared` напрямую
   - `ProgressBar` использует жестко закодированные цвета

10. **Жестко закодированный язык в ViewModels**
    - `ArticleRowViewModel` использует "ru" в computed properties
    - `ArticleDetailViewModel` использует "ru" в PDF экспорте

11. **Дублирование логики перевода**
    - `FavoritesView`, `PDFViewer`, `ReadingProgressBar` имеют дублирующие методы перевода с жестко закодированными словарями

12. **Отсутствие @MainActor изоляции**
    - Большинство View не помечены как `@MainActor` несмотря на работу с @StateObject/@ObservedObject

13. **Нарушение консистентности в менеджерах**
    - `ReadingHistoryManager` НЕ помечен как `@MainActor`, хотя другие менеджеры помечены
    - `CategoryManager` является `actor`, но не `@MainActor`, что создает путаницу
    - `ReadingProgressTracker` хранит данные только в памяти, теряет прогресс между запусками

14. **Дублирование функциональности трекеров**
    - `ReadingHistoryManager` и `ReadingTimeTracker` отслеживают время чтения, но по-разному
    - `ReadingTracker` (вложенный в ReadingHistoryManager) дублирует логику `ReadingTimeTracker`

15. **Нарушение DI в менеджерах**
    - `CategoryManager` использует `DataService.shared` напрямую
    - `ReadingProgressHelper` использует `LocalizationManager.shared` напрямую
    - Все менеджеры используют singleton паттерн вместо DI через AppContainer

16. **Несоответствие хранения данных**
    - Одни менеджеры используют `DefaultsStore`, другие - `UserDefaults`, третьи - `@AppStorage`
    - `ReadingProgressTracker` не сохраняет данные вообще

17. **Жестко закодированные локали в моделях**
    - `Article` использует фиксированные локали (ru_RU, en_US, de_DE) вместо системных
    - `Article` использует `ru_RU` локаль для таджикского языка (tj)
    - Нарушение принципов локализации - должен использоваться системный Locale

18. **Некорректный подсчет слов в Article**
    - Свойство `wordCount` использует приблизительный расчет: `readingTime * 200`
    - Не отражает реальное количество слов, вводит в заблуждение
    - Дублирует логику `ReadingTimeCalculator.countWords(in:)` но неправильно

19. **Хардкод-переводы в модели данных**
    - `Article.getTranslation(key:language:)` содержит жестко закодированные словари
    - Нарушение разделения ответственности - модель не должна заниматься локализацией
    - Дублирует функциональность `LocalizationManager`

20. **Неполная поддержка языков в моделях**
    - `Article` поддерживает только ru, en, de, tj в методах форматирования дат
    - Отсутствует поддержка fa, ar, uk из списка поддерживаемых языков

21. **Нарушение DI в репозиториях и сервисах**
    - `ArticlesRepositoryImpl` использует `DataService.shared` напрямую вместо инжекции
    - `DataService` использует `NetworkService.shared` напрямую
    - Все сервисы используют singleton паттерн вместо DI через AppContainer

22. **Жестко закодированные переводы в LocalizationManager**
    - Полный словарь переводов захардкожен в коде
    - Нет поддержки внешних файлов локализации
    - Сложность поддержки и добавления новых ключей

23. **Смешанные стратегии кэширования**
    - `DataService` кэширует в памяти
    - `NetworkService` кэширует в файловой системе + URLCache
    - Нет единой стратегии управления кэшем

24. **Нарушение ответственности в DataService**
    - Содержит логику загрузки, кэширования, и логирования
    - Слишком высокая связность, нарушение Single Responsibility Principle

25. **Устаревший sync API в NetworkService**
    - `loadJSONSync` метод существует для обратной совместимости
    - Дублирует функциональность async метода

26. **Несоответствие стратегий кэширования между сервисами**
    - `DataService` использует offline-first стратегию (память → локальный JSON → сеть)
    - `NetworkService` использует противоположную стратегию (сеть → файловый кэш → Bundle)
    - Создает путаницу и непредсказуемое поведение при загрузке данных

27. **AuthService является полной заглушкой**
    - Класс существует но не содержит никакой функциональности
    - Только TODO комментарии без реализации
    - Нарушает принцип "working software" - код должен либо работать, либо быть удален

28. **Жестко закодированные переводы в LocalizationManager**
    - Полный словарь из 200+ ключей захардкожен в коде
    - Нет поддержки внешних файлов локализации (.strings)
    - Сложность поддержки и добавления новых ключей
    - Нарушение принципа разделения данных и кода

29. **Несоответствие имен в DefaultsStore**
    - Файл называется `DefaultsStore.swift` но в AI_CONTEXT.md упоминается как `DefaultsStorage`
    - Может вызывать путаницу при поиске и использовании

30. **Разные подходы к асинхронности в сервисах**
    - `DataService` использует `actor` и `async/await`
    - `NetworkService` использует `class` с async методами
    - `ArticlesRepositoryImpl` использует `final class` с async методами
    - Отсутствие консистентности в архитектурных подходах

31. **Несоответствие локализации между моделями**
    - `Article` поддерживает все 7 языков в title и content
    - `Category` поддерживает только 4 языка (`ru`, `en`, `de`, `tj`)
    - `Location` не поддерживает локализацию вообще
    - Нарушение консистентности данных и пользовательского опыта

32. **Разные стратегии идентификаторов**
    - `Article.id` и `Category.id` используют UUID-формат
    - `Location.id` использует простые строки ("1", "2", "3")
    - Отсутствие единого стандарта идентификации сущностей

33. **Неполнота данных locations.json**
    - Всего 3 локации в файле, что недостаточно для полноценной карты
    - Отсутствие важных локаций (банки, университеты, Bürgeramt в других городах)
    - Названия локаций не локализованы, только на немецком/русском

34. **Markdown-контент в статьях**
    - Контент статей использует Markdown-разметку, но в AI_CONTEXT.md не указано
    - Может требовать специальной обработки при отображении
    - Не документированы поддерживаемые Markdown-теги

35. **Отсутствие обязательных полей в JSON**
    - Не указано какие поля обязательные/опциональные
    - Например, `pdfFileName` опционально в articles.json
    - Может привести к ошибкам парсинга если ожидаются обязательные поля

### 🟡 Планы исправления

**Высокий приоритет:**
- Рефакторинг UI компонентов для использования инжектированных зависимостей вместо shared-инстансов
- Создание протоколов для менеджеров и интеграция их в AppContainer
- Исправить ContentView для использования AppContainer
- Унифицировать управление категориями (выбрать один подход)
- Обновить AppContainer.makeCategoriesViewModel()

**Средний приоритет:**
- Интегрировать новые менеджеры трекинга в DI
- Заменить жестко закодированный язык на динамический из настроек
- Добавить @MainActor изоляцию для всех View
- Обновить тесты для нового функционала

**Низкий приоритет:**
- Унифицировать подход к локализации между компонентами
- Убрать дублирующие методы перевода
- Создать общие компоненты для повторяющихся паттернов

---

## 8) Обновление контекста

- Меняется модель/интерфейс → обновить §2b/2c.  
- Обновляется структура → запустить `./scripts/update_project_tree.sh 3`.  
- Новый коммит/ветка → обновить `Docs/git_snapshot.md`.  
- Все изменения фиксировать в `Docs/CHANGELOG.md`.  
- Коммит:  
  ```bash
  git commit -m "docs(context): обновлён AI_CONTEXT"
  ```

### Documentation
- [2025-10-06] Полное обновление AI_CONTEXT.md на основе анализа кодовой базы:
  - Обновлены разделы 2b (Модели, Менеджеры, Сервисы, UIUtils) с реальными деталями реализации
  - Выявлены и документированы 25 критических проблем архитектуры
  - Добавлены точные описания всех сервисов с их зависимостями и стратегиями
  - Обновлена информация о тестах с учетом реального покрытия
  - Уточнены все singleton зависимости и нарушения DI принципов

- [2025-10-05] Добавлены `///` doc-комментарии ко всем основным моделям, менеджерам, сервисам, утилитам и view model
- [2025-10-05] Добавлен  Новый скрипт/автоматизация → обновить §9
- [2025-10-06] Добавлен скрипт release.sh для автоматической генерации CHANGELOG и управления релизами

- [2025-10-06] Обновлен AI_CONTEXT.md с разделом автоматизации релизов

### JSON-данные

В проекте используются локальные JSON-файлы как fallback-источники при отсутствии сети.  
Загружаются через `DataService` (`loadLocalArticles`, `loadLocalCategories`, `loadLocalLocations`).

- **articles.json** — список статей (id, title, content, categoryId, tags, даты, изображения, pdfFileName).  
- **categories.json** — список категорий (id, локализованные названия, иконки).  
- **locations.json** — список географических объектов (например, Ausländerbehörde, Bürgeramt, посольства).  
  - Структура описана в файле [`Docs/locations_README.md`](Docs/locations_README.md).  
  - Используется для отображения точек на карте (`MapView`) и работы с моделью `Location`.

**При работе с JSON-данными:**
- Всегда проверяйте наличие всех языковых ключей при локализации
- Учитывайте что categories.json не содержит переводы для fa/ar/uk
- locations.json содержит минимальный набор данных для демонстрации
- Контент статей требует Markdown-парсинга для корректного отображения
- Даты в строковом формате ISO8601 требуют специальной обработки в моделях

**При работе с сервисами:**
- `DataService` и `NetworkService` имеют противоположные стратегии кэширования - учитывайте это
- `ArticlesRepositoryImpl` является тонкой прокладкой над `DataService` без дополнительной логики
- `AuthService` не реализован - не пытайтесь его использовать
- `LocalizationManager` содержит полный словарь переводов в коде - не ищите внешние файлы
- `DefaultsStore` предоставляет универсальные методы для Codable объектов в UserDefaults
