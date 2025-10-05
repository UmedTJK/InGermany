# InGermany · AI_CONTEXT.md

> Единый контекст для ИИ-агентов. Задача — обеспечить моментальное понимание проекта и выпуск **релевантного, безопасного и соответствующего стандартам** кода. Документ публикуется в репозитории и прикладывается ко всем запросам к ИИ-агентам.

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
5. **Concurrency-чистота.**  
6. **UI = Apple HIG.**  
7. **Документируемое изменение.**

---

## 2) Архитектура и структура проекта

* **Core/**: `InGermanyApp.swift`, `ContentView.swift`  
* **Models/**: `Article.swift`, `Category.swift`, `Location.swift`  
* **Services/**:  
  - `DataService.swift`  
  - `NetworkService.swift`  
  - `ShareService.swift`  
  - `AuthService.swift`  
  - `DefaultsStore.swift`  
  - `ExportToPDF.swift`  
  - `LocalizationManager.swift`  
* **Managers/**:  
  - `FavoritesManager.swift`  
  - `RatingManager.swift`  
  - `ReadingHistoryManager.swift`  
  - `ReadingTimeTracker.swift`  
  - `TextSizeManager.swift`  
  - `ReadingProgressHelper.swift`  
  - `ReadingProgressTracker.swift`  
  - `ReadingTimeCalculator.swift`  
* **Protocols/**:  
  - `ArticlesRepository.swift`  
  - `CategoriesRepository.swift`  
  - (другие протоколы для сервисов, менеджеров и репозиториев)  
* **UIUtils/**:  
  - `Theme.swift`  
  - `Animations.swift`  
  - `CardSize.swift`  
  - `Color+Hex.swift`  
  - `ProgressBar.swift`  
* **Formatters/**:  
  - `DateFormatter+Localized.swift`  
  - `ReadingTimeFormatter.swift`  
  - (другие форматтеры для дат, времени, текста)  
* **Views/**: `HomeView`, `SearchView`, `FavoritesView`, `CategoriesView`, `ArticlesByCategoryView`, `ArticlesByTagView`, `ArticleDetailView`, `SettingsView`, `AboutView`, `MapView`  

  - **HomeView.swift** — оболочка для главного экрана: отвечает за загрузку/обновление данных и навигацию. 
  - **Sections/** — новые компоненты для секций главного экрана:
    - `UsefulToolsSection.swift` — блок «Полезные инструменты».
    - `RecentlyReadSection.swift` — блок «Недавно прочитанное».
    - `FavoritesSection.swift` — блок «Избранное».
    - `CategorySection.swift` — горизонтальные ленты статей по категориям.
    - `AllArticlesSection.swift` — блок со всеми статьями.
> Начиная с v1.8.7, `HomeView` больше не содержит внутреннюю разметку секций. Все UI-блоки вынесены в отдельные вью для упрощения сопровождения и работы ИИ-агентов.

* **Views/Components/**: `ArticleCardView`, `ArticleRow`, `ArticleMetaView`, `ArticleCompactCard`, `FavoriteCard`, `RecentArticleCard`, `ToolCard`, `EmptyFavoritesView`, `CategoryFilterButton`, `TagFilterView`, `TextSizeSettingsPanel`, `ReadingProgressBar`, `ReadingProgressView`, `CircularReadingProgress`, `PDFViewer`  
* **Resources/**: `articles.json`, `categories.json`, `locations.json`  
* **Docs/**: `AI_CONTEXT_v2.md`, `CHANGELOG.md`, `PROMPTS_FOR_AI_AGENTS.md`, `Git_Mini_Guide.md`, `CLEAN_CODE_CHECKLIST.md`, `git_snapshot.md`, `project_tree.md`  
* **Docs (архив)**: `PROJECT_STRUCTURE.md`, `Project_Brief.docx`  
* **Корень**: `.swiftlint.yml`, `README.md`, `update.sh`

### Dependency Injection и AppContainer (с версии v1.10.0)

Для управления зависимостями используется `AppContainer` (Composition Root), помеченный `@MainActor`.  
AppContainer создаёт экземпляры ViewModel и менеджеров, централизуя конфигурацию приложения.

- **AppContainer**
  - `articlesRepo: ArticlesRepository` → реализован через `ArticlesRepositoryImpl`
  - `categoriesRepo: CategoriesRepository` → singleton `.shared`
  - `favoritesManager: FavoritesManager` → singleton `.shared`
  - `historyManager: ReadingHistoryManager` → singleton `.shared`
  - `makeHomeViewModel()` → возвращает готовый `HomeViewModel`
  - `makeSettingsViewModel()` → возвращает готовый `SettingsViewModel`
  - `makeArticleDetailViewModel()` → возвращает готовый `ArticleDetailViewModel`
  - `makeAboutViewModel()` → возвращает готовый `AboutViewModel`

- **HomeViewModel**
  - Теперь зависит от `ArticlesRepository`, `FavoritesManager`, `ReadingHistoryManager`, `CategoriesRepository`
  - Основной init принимает все зависимости
  - Есть `convenience init()` для старых вызовов и превью
  - Методы `loadData()` и `refreshData()` используют `articlesRepo`, а не напрямую `DataService`

- **SettingsViewModel**
  - Управляет настройками и историей чтения.
  - Зависимости: `ReadingHistoryManager`.
  - Состояния: `selectedLanguage`, `isHistoryCleared`.
  - Методы: `clearHistory()`, `changeLanguage(to:)`.

- **ArticleDetailViewModel**
  - Управляет состоянием экрана статьи.
  - Зависимости: `FavoritesManager`, `ReadingHistoryManager`.
  - Состояния: `article`, `allArticles`, `isFavorite`.
  - Методы: `toggleFavorite()`, `exportToPDF()`, `markAsRead()`.

- **HomeView**
  - Не создаёт VM напрямую.
  - При инициализации по умолчанию использует `AppContainer.shared.makeHomeViewModel()`
  - В тестах/превью может принимать кастомный VM.

- **SettingsView**
  - Теперь работает с `SettingsViewModel`.
  - Управление настройками и очисткой истории вынесено во ViewModel.

- **ArticleDetailView**
  - Теперь работает с `ArticleDetailViewModel`.
  - Функции: управление избранным, экспорт PDF, учёт истории чтения.

---

## 2a) Структура проекта (актуальная)

Полное дерево проекта хранится в файле: `Docs/project_tree.md`

> ⚠️ Обновляется вручную командой:
> ```bash
> cd ~/Desktop/InGermany
> tree -L 3 > Docs/project_tree.md
> ```

---

## 2b) Потоки данных, менеджеры и хранение

### Модели

- **Article**  
  `id, title:[String:String], content:[String:String], categoryId, tags, pdfFileName?, createdAt?, updatedAt?, image?`  
  Методы: `localizedTitle`, `localizedContent`, `formattedCreatedDate`, `formattedUpdatedDate`, `readingTime`, `formattedReadingTime`.

- **Category**  
  `id, name:[String:String], icon (SF Symbol), colorHex`  
  Метод: `localizedName(for:)`.

- **Location**  
  `id, name, latitude, longitude`  
  Свойство: `coordinate: CLLocationCoordinate2D`.

### Менеджеры состояния

- **FavoritesManager**  
  `@AppStorage("favoriteArticles")` → JSON `Set<String>`  
  Методы: `isFavorite(id:)`, `toggleFavorite(id:)`, `favoriteArticles(from:)`.

- **RatingManager**  
  Хранение: `UserDefaults` (`rating_<articleId>`)  
  Методы:  
  - `getRating(for:) -> Int` — получить рейтинг статьи  
  - `setRating(_:for:)` — установить рейтинг  
  Используется в `ArticleCardView`, `ArticleCompactCard`, `ArticleMetaView` через биндинги в `StarRatingView`.

- **ReadingHistoryManager**  
  Хранение: `@AppStorage("readingHistory")` JSON массив `ReadingHistoryEntry`.  
  Методы: `addReadingEntry`, `recentlyReadArticles`, `isRead`, `lastReadDate`, `clearHistory`.  
  Ограничение: максимум 100 записей.  
  Вспомогательные: `ReadingTracker`, `ReadingStats`. let totalReadingTimeSeconds: Int   // учитываются секунды

- **CategoryManager (actor)**  
  Методы: `loadCategories()`, `allCategories()`, `category(for id:)`, `category(for name:language:)`, `refreshCategories()`.

- **CategoriesStore (ObservableObject)**  
  Published: `categories:[Category]`, `byId:[String:Category]`.  
  Методы: `bootstrap()`, `refresh()`, `category(for:)`, `categoryName(for:)`.

- **TextSizeManager (ObservableObject)**  
  Хранение: `UserDefaults` (`articleFontSize`, `isCustomTextSizeEnabled`).  
  Методы: `presetSizes`, `resetToDefault()`, `currentFont`.

---

### Сервисы

- **DataService (actor)**  
  Приоритет загрузки: память → Bundle JSON → сеть.  
  Методы: `loadArticles`, `loadCategories`, `loadLocations`, `refreshData`, `clearCache`, `getLastDataSource`.

- **NetworkService**  
  Приоритет: сеть → cache (~/Library/Caches/InGermanyCache) → Bundle.  
  Методы: `loadJSON<T:Decodable>(from:)`, `loadJSONSync<T>(from:completion:)`, `clearCache`.

- **ShareService**  
  Метод: `shareArticle(_:language:)` → iOS Share Sheet.

- **AuthService**  
  Заглушка.

---


### Новые папки и их содержимое

- **Protocols/**  
  - `ArticlesRepository.swift`  
  - `CategoriesRepository.swift`  
  - (другие протоколы для сервисов, менеджеров и репозиториев)

- **UIUtils/**  
  - `Theme.swift`  
  - `Animations.swift`  
  - `CardSize.swift`  
  - `Color+Hex.swift`  
  - `ProgressBar.swift`

- **Formatters/**  
  - `DateFormatter+Localized.swift`  
  - `ReadingTimeFormatter.swift`  
  - (другие форматтеры для дат, времени, текста)

---

### UI-компоненты

- **TextSizeSettingsPanel** — экран настройки текста.  
- **TagFilterView** — фильтр тегов.  
- **ReadingProgressBar / ReadingProgressView / CircularReadingProgress** — прогресс чтения.  
- **PDFViewer** — рендер PDF из Bundle.  
- **FavoriteCard** — карточка избранного.  
- **Components.swift**: `ToolCard`, `RecentArticleCard`, `EmptyFavoritesView`, `CategoryFilterButton`.  
- **Animations.swift**: `.cardStyle()`, `.scaleOnAppear()`, `.shimmer()`, haptic feedback.  
- **ArticleCardView** — карточка статьи в сетке.  
- **ArticleMetaView** — категория, даты, бейджи.  
- **ArticleRow** — строка списка статей, работает через `ArticleRowViewModel` (MVVM).
- **ArticleCompactCard** — компактная карточка статьи, используемая в списках и секциях.
  Включает:
  - изображение статьи (с поддержкой стиля через `CardImageStyle`),
  - заголовок (2 строки, выравнивание по левому краю),
  - короткий анонс (до 2 строк из начала текста),
  - блок метаданных:
    - рейтинг из `RatingManager` (через `StarRatingView`),
    - прогресс чтения через `ReadingProgressTracker`,
    - время чтения (`Article.formattedReadingTime`).
  Поддерживает динамический размер текста через `TextSizeManager`.
  Размер: ширина 320pt, высота изображения 280pt, фон `systemBackground`, скруглённые углы и тень.


### MVVM + Dependency Injection (с версии v1.11.0)

Архитектура проекта переведена на использование централизованного DI через `AppContainer` и MVVM для основных экранов.

#### AppContainer
- Реализован как Composition Root, помечен `@MainActor`.
- Отвечает за создание и хранение зависимостей.
- Методы-фабрики:
  - `makeHomeViewModel()`
  - `makeFavoritesViewModel()`
  - `makeSearchViewModel()`
  - `makeCategoriesViewModel()`
  - `makeSettingsViewModel()`
  - `makeArticleDetailViewModel()`

#### ViewModels
- **HomeViewModel**
  - Управляет данными главного экрана.
  - Работает с `ArticlesRepository`, `FavoritesManager`, `ReadingHistoryManager`, `CategoriesRepository`.
  - Методы: `loadData()`, `refreshData()`, `selectRandomArticle()`.

- **FavoritesViewModel**
  - Управляет списком избранного.
  - Зависимости: `FavoritesManager`, `ArticlesRepository`.
  - Методы: `loadFavorites()`, `toggleFavorite(for:)`.
  - Публичные состояния: `favoriteArticles`, `allArticles`, `isLoading`, `dataSource`.

- **SearchViewModel**
  - Управляет логикой поиска и фильтрации.
  - Зависимости: `FavoritesManager`, `CategoriesRepository`, `ArticlesRepository`.
  - Состояния: `articles`, `searchText`, `selectedTag`, `isLoading`, `dataSource`.
  - Вычисляемые свойства: `filteredArticles`, `allTags`.

- **CategoriesViewModel**
  - Управляет загрузкой категорий и связанных статей.
  - Зависимости: `CategoriesRepository`, `ArticlesRepository`, `FavoritesManager`.
  - Методы: `loadData()`.
  - Состояния: `categories`, `articles`, `isLoading`.

- **SettingsViewModel**
  - Управляет настройками и историей чтения.
  - Зависимости: `ReadingHistoryManager`.
  - Состояния: `selectedLanguage`, `isHistoryCleared`.
  - Методы: `clearHistory()`, `changeLanguage(to:)`.

- **ArticleDetailViewModel**
  - Управляет состоянием экрана статьи.
  - Зависимости: `FavoritesManager`, `ReadingHistoryManager`.
  - Состояния: `article`, `allArticles`, `isFavorite`.
  - Методы: `toggleFavorite()`, `exportToPDF()`, `markAsRead()`.
    - Теперь работает с `ArticleDetailViewModel`.
  - Функции: управление избранным, экспорт PDF, учёт истории чтения.
  - Оптимизирован: вынесены вычисляемые свойства (`ratingBinding`, `articleContent`).
  - Для связанных статей теперь используется `ArticleRow(viewModel:)`.
  
- **ArticleRowViewModel**
  - Управляет отображением строки статьи (`ArticleRow`).
  - Зависимости: `FavoritesManager`, `RatingManager`.
  - Состояния: `isFavorite`, `rating`, `title`, `subtitle`, `metaInfo`.
  - Методы: `toggleFavorite()`, `setRating(_:)`.

- **AboutViewModel**
  - Управляет экраном «О приложении».
  - Состояния: `appVersion`, `buildNumber`, `repositoryURL`.
  - Локализация выполняется через `LocalizationManager`.

#### Views
- **HomeView**
  - Получает `HomeViewModel` из `AppContainer`.
  - ViewModel полностью управляет данными и состоянием.

- **FavoritesView**
  - Теперь работает через `FavoritesViewModel`.
  - Управление избранным (загрузка, фильтрация, добавление/удаление) вынесено во ViewModel.
  - ViewModel отвечает за фильтрацию и загрузку избранных статей.

- **SearchView**
  - Работает с `SearchViewModel`.
  - Фильтрация по тегам и поисковому тексту вынесена во ViewModel.
  - View остаётся чисто декларативной.

- **CategoriesView**
  - Работает с `CategoriesViewModel`.
  - Не принимает параметры `articles` и `favoritesManager` напрямую, получает их через DI.

- **SettingsView**
  - Теперь работает с `SettingsViewModel`.
  - Управление настройками и очисткой истории вынесено во ViewModel.

- **ArticleDetailView**
  - Теперь работает с `ArticleDetailViewModel`.
  - Функции: управление избранным, экспорт PDF, учёт истории чтения.

#### ContentView
- Убран вызов `SearchView(favoritesManager:, articles:)`.
- Теперь используется просто `SearchView()`, так как зависимости берутся через DI.
- `CategoriesView` теперь также переведён на MVVM через DI.

- **AboutView**
  - Теперь работает через `AboutViewModel`.
  - Отображает описание приложения, версию, билд и ссылку на GitHub.

---

📌 Важно: теперь весь код соответствует принципам **SOLID** и паттерну **MVVM**, зависимости централизованы, Views максимально «тонкие».

### Экраны

- **HomeView**  
  Секции: «Полезные инструменты» (MapView, PDFViewer, Random Article), «Недавно прочитанное», «Избранное», категории, «Все статьи».  
  Работает с: `favoritesManager`, `categoriesStore`, `ReadingHistoryManager`.

- **MapView**  
  Отображает `locations.json` (через DataService).  
  Toolbar: «Моё местоположение», «Обновить».

- **SearchView**  
  Поиск по тексту, тегам, категориям.  
  Использует: `TagFilterView`, `ArticleRow`.


- **SettingsView**  
  Управление настройками приложения (тема, размер текста, формат даты, история чтения, About).
  ✅ Язык интерфейса теперь выбирается из списка с флагами и названием языка, текущий язык отмечен галочкой.
  Теперь работает с `SettingsViewModel`.
  Управление настройками и очисткой истории вынесено во ViewModel.

- **ArticleDetailView**  
  Полный экран статьи.  
  Функции: PDF, избранное.  

- **ArticlesByTagView** — список по тегу.  
- **CategoriesView** — список категорий.  
- **FavoritesView**  
  - Теперь работает с `FavoritesViewModel`.
  - Загружает и фильтрует избранные статьи через ViewModel.
  - View остаётся декларативным, вся логика вынесена во ViewModel.
- **AboutView** — информация о проекте.  

---

## 2c) Публичные интерфейсы

> 📎 Все таблицы интерфейсов сведены по категориям: модели, сервисы, менеджеры, утилиты, UI и экраны.  
> Формат: **Класс/Файл** → метод/свойство → входные параметры → возвращает → комментарий.  
> (см. подробные таблицы в подготовленных блоках; при обновлении API фиксировать в этом разделе).

#### Управление размером текста
- Ранее выбор осуществлялся через enum `TextSize` (small/medium/large).  
- Начиная с v1.9.0 управление перенесено на `Slider` с диапазоном **0.8 ... 1.5** (80%–150%).  
- Новое поле `TextSizeManager.customScale: Double` хранит текущее значение масштаба и сохраняется в `DefaultsStorage`.  
- Enum `TextSize` по-прежнему используется для функции «Сбросить» и обратной совместимости.  
- `ArticleDetailView` и все текстовые представления теперь используют `customScale` вместо жёсткой привязки к `TextSize.scale`.


## 3) Ресурсы

- `Resources/articles.json`  
- `Resources/categories.json`  
- `Resources/locations.json`  
- `Assets.xcassets` (логотипы, иконки)  
- `Docs/*` (AI_CONTEXT, project_tree, git_snapshot и др.)  
- `update.sh`

---

## 4) Дорожная карта

См. Roadmap в `README.md` и `CHANGELOG.md`.  
Основные направления: улучшение UI, поддержка сетевой загрузки, unit-тесты ViewModel, расширение контента.

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

Актуальный снимок git хранится в: `Docs/git_snapshot.md`.

---

## 6) Обновление контекста

- Меняется модель/интерфейс → обновить §2b/2c.  
- Обновляется структура → перегенерировать `Docs/project_tree.md`.  
- Новый коммит/ветка → обновить `Docs/git_snapshot.md`.  
- Все изменения фиксировать в `Docs/CHANGELOG.md`.  
- Коммит:  
  ```bash
  git commit -m "docs(context): обновлён AI_CONTEXT"
  ```

### Documentation
- [2025-10-03] Добавлены `///` doc-комментарии ко всем основным моделям, менеджерам, сервисам, утилитам и view model:
  - `Article`
  - `DataService`
  - `FavoritesManager`
  - `CategoryManager`
  - `LocalizationManager`
  - `RatingManager`
  - `ReadingHistoryManager`
  - `ReadingTimeCalculator`
  - `ReadingTimeTracker`
  - `DefaultsStore`
  - `Theme`
  - `Animations`
  - `ArticleRowViewModel`
- Обновлён `CLEAN_CODE_CHECKLIST.md` — теперь пункт про обязательные `///` комментарии у публичных классов и методов.

- [2025-10-03] v1.12.2 bugfix: восстановлено корректное отображение миниатюр статей из Bundle.
  - Добавлена поддержка `.avif → .jpg` (автоматическая конвертация расширения).
  - Добавлен fallback для изображений без расширения.
  - Улучшена надёжность загрузки миниатюр (thumbnail) для статей.

- [2025-10-04] Добавлены `///` doc-комментарии для всех секций:
  - `AllArticlesSection`
  - `FavoritesSection`
  - `RecentlyReadSection`
  - `CategorySection`
  - `UsefulToolsSection`
  - PR #9 (draft) фиксирует этот этап документации.

### JSON-данные

В проекте используются локальные JSON-файлы как fallback-источники при отсутствии сети.  
Загружаются через `DataService` (`loadLocalArticles`, `loadLocalCategories`, `loadLocalLocations`).

- **articles.json** — список статей (id, title, content, categoryId, tags, даты, изображения, pdfFileName).  
- **categories.json** — список категорий (id, локализованные названия, иконки).  
- **locations.json** — список географических объектов (например, Ausländerbehörde, Bürgeramt, посольства).  
  - Структура описана в файле [`Docs/locations_README.md`](Docs/locations_README.md).  
  - Используется для отображения точек на карте (`MapView`) и работы с моделью `Location`.  
### Unit Tests (XCTest)

- ✅ **FavoritesManagerTests.swift** — проверка добавления/удаления избранного и фильтрации статей.  
- ✅ **CategoryManagerTests.swift** — проверка загрузки категорий, поиска по ID/имени, обновления данных.  
- ✅ **DataServiceTests.swift** — проверка корректной работы с JSON (articles, categories), edge-кейсы: пустые/битые данные.  
- ✅ **InGermanyTests.swift** — smoke-тесты (инициализация приложения, работа FavoritesManager и DataService).  

📌 **Следующие шаги (roadmap по тестам):**

#### 1. ViewModels
- [ ] **HomeViewModelTests** — проверка загрузки данных, обновления, выбора случайной статьи.  
- [ ] **FavoritesViewModelTests** — загрузка избранных статей, переключение статуса избранного.  
- [ ] **SearchViewModelTests** — фильтрация по тексту, тегам, категориям, edge-кейсы (пустой ввод).  
- [ ] **CategoriesViewModelTests** — загрузка категорий и связанных статей, проверка состояния `isLoading`.  
- [ ] **SettingsViewModelTests** — смена языка, очистка истории, проверка `isHistoryCleared`.  
- [ ] **ArticleDetailViewModelTests** — избранное, экспорт в PDF, история чтения.  

#### 2. UI / Snapshot
- [ ] **Snapshot-тесты** для основных экранов (`HomeView`, `SearchView`, `ArticleDetailView`).  
- [ ] **Accessibility-тесты** (VoiceOver, Dynamic Type).  

#### 3. Services / Managers (расширение)
- [ ] **NetworkServiceTests** — обработка ошибок сети, кеширование, загрузка JSON.  
- [ ] **ReadingHistoryManagerTests** — добавление/очистка истории, ограничение в 100 записей.  
- [ ] **RatingManagerTests** — установка и получение рейтинга, edge-кейсы.  

#### 4. Интеграция
- [ ] GitHub Actions workflow для запуска тестов при каждом PR.  
- [ ] Генерация отчётов о покрытии кода (например, Slather + GitHub Actions).  


### Unit Tests (XCTest)

- ✅ **FavoritesManagerTests.swift** — проверка добавления/удаления избранного и фильтрации статей.  
- ✅ **CategoryManagerTests.swift** — проверка загрузки категорий, поиска по ID/имени, обновления данных.  
- ✅ **DataServiceTests.swift** — проверка корректной работы с JSON (articles, categories), edge-кейсы: пустые/битые данные.  
- ✅ **FavoritesViewModelTests.swift** — комплексное тестирование ViewModel избранного: состояния загрузки, переключение избранного, источник данных.  
- ✅ **InGermanyTests.swift** — smoke-тесты (инициализация приложения, работа FavoritesManager и DataService).  

📌 **Следующие шаги (roadmap по тестам):**
- [ ] **HomeViewModelTests** — проверка загрузки данных, обновления, выбора случайной статьи.  
- [ ] **SearchViewModelTests** — фильтрация по тексту, тегам, категориям.  


# Обновим раздел тестов в AI_CONTEXT.md
# (можно сделать вручную или через sed/awk)

echo "### Unit Tests (XCTest)

- ✅ **ArticleDetailViewModelTests** — полное покрытие управления избранным, историей чтения, логики связанных статей
- ✅ **FavoritesManagerTests** — проверка добавления/удаления избранного и фильтрации статей  
- ✅ **CategoryManagerTests** — проверка загрузки категорий, поиска по ID/имени, обновления данных
- ✅ **DataServiceTests** — проверка корректной работы с JSON (articles, categories), edge-кейсы: пустые/битые данные
- ✅ **FavoritesViewModelTests** — комплексное тестирование ViewModel избранного: состояния загрузки, переключение избранного, источник данных
- ✅ **InGermanyTests.swift** — smoke-тесты (инициализация приложения, работа FavoritesManager и DataService)

📌 **Следующие шаги (roadmap по тестам):**
- [ ] **ArticleRowViewModelTests** — тестирование управления состоянием строки статьи
- [ ] **CategoriesViewModelTests** — тестирование загрузки категорий и связанных статей
- [ ] **HomeViewModelTests** — проверка загрузки данных, обновления, выбора случайной статьи  
- [ ] **SearchViewModelTests** — фильтрация по тексту, тегам, категориям
- [ ] **SettingsViewModelTests** — смена языка, очистка истории, настройки" > temp_context.txt



### Current Test Coverage Status

✅ **ArticleDetailViewModelTests** — полное покрытие управления избранным, историей чтения, логики связанных статей
✅ **HomeViewModelTests** — проверка загрузки данных, обновления, выбора случайной статьи
✅ **FavoritesManagerTests** — проверка добавления/удаления избранного и фильтрации статей  
✅ **CategoryManagerTests** — проверка загрузки категорий, поиска по ID/имени, обновления данных
✅ **DataServiceTests** — проверка корректной работы с JSON (articles, categories), edge-кейсы: пустые/битые данных
✅ **FavoritesViewModelTests** — комплексное тестирование ViewModel избранного
✅ **InGermanyTests.swift** — smoke-тесты

**Next Targets:**
- ArticleRowViewModelTests
- CategoriesViewModelTests  
- SearchViewModelTests
- SettingsViewModelTests

