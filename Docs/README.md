
# 📖 AI_CONTEXT.md — InGermany (обновлено 11.10.2025)

> ⚠️ ВНИМАНИЕ: это обновлённая версия. Старый файл (`Docs/AI_CONTEXT.md`) оставлен для истории.  

> Здесь зафиксированы последние архитектурные изменения, включая переход на AppContainer и объединение менеджеров в ReadingStatsManager.

Этот файл — главный справочник для ИИ-агента по проекту **InGermany**.
Задача: дать полное понимание текущего состояния, архитектуры, функций и планов развития проекта.

---

## 👨‍💻 1. Разработчик и контакты

* Автор: **Umed Sabzaev**
* GitHub: [UmedTJK](https://github.com/UmedTJK/InGermany)
* LinkedIn: [Umed Sabzaev](https://www.linkedin.com/in/umed-sabzaev)
* Email: [umedsbz@gmail.com](mailto:umedsbz@gmail.com)

---

## 🏗️ 2. Структура проекта

### 📂 Основные директории

* **Core/** → DI-контейнер и точка входа (`AppContainer`, `InGermanyApp`, `ContentView`)
* **Managers/** → управление состоянием и аналитикой (Favorites, Ratings, TextSize, ReadingStats, Categories, Cache и др.)
* **Services/** → инфраструктурные сервисы (Localization, DataService, NetworkService, PDF, DefaultsStore, ShareService и др.)
* **Repositories/** → абстракции и реализации для работы с данными (`ArticlesRepository`, `CategoriesRepository`, протоколы)
* **Models/** → основные модели (`Article`, `Category`, `Location`, `ReadingSession`)
* **ViewModels/** → бизнес-логика экранов (Home, Search, ArticleDetail, Settings и др.)
* **Views/** → UI на SwiftUI (HomeView, ArticleDetailView, SettingsView и др.)
* **UIUtils/** → стили и эффекты (Theme, Animations, CardStyle, CardImageStyle, ProgressBar и др.)
* **Docs/** → документация (README, CHANGELOG, AI_CONTEXT, ARCHITECTURE_ISSUES и др.)
* **InGermanyTests/** → тесты (Unit, UI, Mocks, Resources)

---

### 🔑 Архитектурные паттерны

* **MVVM** (View ↔ ViewModel ↔ Repository ↔ Service/Manager)
* **Dependency Injection** через `AppContainer`
* **SOLID** принципы (разделение ответственности, протоколы для тестирования)
* **Unit-тесты** с Mock-реализациями репозиториев и менеджеров
* **CI/CD** пока вручную (shell-скрипты: release, update, check_di_violations)

---

### 🧩 Core

* **InGermanyApp.swift** — точка входа, создаёт `AppContainer` и прокидывает зависимости.
* **ContentView.swift** — корневой экран, `TabView` с ленивыми вкладками (`LazyView`), создаёт ViewModels через контейнер.
* **AppContainer.swift** — DI-контейнер:

  * синглтоны (`FavoritesManager`, `TextSizeManager`, `LocalizationManager`, `RatingManager`, `ReadingStatsManager`)
  * фабрики для ViewModels (`makeHomeViewModel`, `makeSearchViewModel`, `makeArticleDetailViewModel` и др.)
  * метод `bootstrap()` для preload локализаций и данных

---

### 🧩 Managers

* **FavoritesManager** — избранные статьи (`DefaultsStore`).
* **RatingManager** — рейтинги статей (`UserDefaults`, JSON).
* **TextSizeManager** — хранение размера текста, реализует `FontProviding`.
* **ReadingStatsManager** — единый менеджер чтения:

  * история и прогресс,
  * управление сессиями,
  * оценка времени и статистики,
  * агрегированная модель `ReadingStats`.

🔄 Ранее существовали `ReadingHistoryManager`, `ReadingTimeTracker`, `ReadingProgressTracker`.
Их функционал объединён в **ReadingStatsManager**, устаревшие файлы и тесты удалены.

* **ReadingProgressHelper** — утилита для UI-индикации прогресса (цвета, статусы, подписи).
* **ReadingTimeCalculator** — оценка времени чтения (WPM для разных языков).
* **CategoryManager** — управление категориями, реализует `CategoriesRepositoryProtocol`, работает через `DataService`.
* **CacheManager** — актор для кеша в памяти с TTL.

---

### 🧩 Services

* **LocalizationManager** — управление мультиязычностью (RU, EN, DE, TJ, FA, AR, UK).
* **DataService** — загрузка JSON (articles, categories), работает через **NetworkService**.
* **NetworkService** — offline-first: `Bundle` → `File Cache` → `Network`.
* **DefaultsStore** — сохранение Codable-объектов в `UserDefaults`.
* **ExportToPDF** — экспорт статьи в PDF (метаданные, Documents-папка).
* **ShareService** — системное окно шаринга статей, plain text + форматированный.
* **ArticleFormatter** — форматирование дат, слов, времени чтения (через DateFormattingService, TextAnalysisService).
* **DateFormattingService** — форматирование дат и relative time (RU, EN, DE, TJ).
* **TextAnalysisService** — word count + reading time (языки EN, DE, RU, TJ).
* **AuthService** — заготовка для авторизации (TODO).

---

### 🧩 Repositories & Protocols

* **ArticlesRepositoryProtocol** — контракт: `loadArticles()`, `refreshArticles()`, `getLastSource()`.
* **ArticlesRepositoryImpl** — реализация, использует **DataService** и `CacheManager`.
* **CategoriesRepositoryProtocol** — контракт: `bootstrap()`, `refresh()`, `category(by:)`, `allCategories()`.
* **DefaultCategoriesRepository** — реализация, хранит список и словарь ID → Category, загружает из **DataService**.
* **ArticleFormatterProtocol** — контракт для форматтера статей (даты, слова, чтение).
* **ArticleFormatter** — реализация, fallback для базовых строк.

---

### 🧩 Models

* **Article** — основная модель статьи, локализация, теги, даты, картинка, word count, свойства `isNew`, `isUpdatedRecently`.
* **Category** — категория статьи (локализованные имена, иконка, цвет).
* **Location** — геолокация для Apple Maps (`coordinate`).
* **ReadingSession** — сессия чтения (`startTime`, `endTime?`, `duration`).

---

### 🧩 ViewModels

* **HomeViewModel** — управление состоянием главного экрана: статьи, категории, случайная статья, загрузка данных.
* **SearchViewModel** — поиск и фильтрация статей по тексту и тегам, управление состоянием поиска.
* **ArticleDetailViewModel** — детали статьи: прогресс чтения, рейтинг, избранное, связанные статьи, шаринг.
* **SettingsViewModel** — настройки приложения: язык, тема, стили карточек, статистика чтения, сброс данных.
* **ArticleRowViewModel** — представление статьи в списках: данные для отображения, управление избранным и рейтингом.
* **ArticleCompactCardViewModel** — компактные карточки статей: зависимости и вычисляемые данные для UI.
* **CategoriesViewModel** — управление категориями и статьями для экрана категорий.
* **FavoritesViewModel** — список избранных статей с загрузкой и управлением.
* **AboutViewModel** — информация о приложении: версия, сборка, репозиторий.
* **LocationsViewModel** — геолокации для карты с загрузкой данных.
* **PDFViewerViewModel** — просмотр PDF с локализацией.
* **ViewModels.swift** — вспомогательный файл-пространство имён для ViewModels.

---

### 🧩 Views

#### Основные экраны:
* **HomeView** — главный экран с секциями: полезные инструменты, недавно прочитанные, избранные, категории, все статьи.
* **ArticleDetailView** — детальный просмотр статьи с прогресс-баром, рейтингом, связанными статьями, панелью размера текста.
* **SearchView** — поиск по статьям с фильтрацией по тегам и навигацией к детальному просмотру.
* **SettingsView** — настройки: язык, внешний вид, стили карточек, статистика, сброс данных.
* **FavoritesView** — список избранных статей с поиском и индикатором источника данных.
* **CategoriesView** — список категорий с навигацией к статьям по категориям.
* **MapView** — карта с локациями, отслеживанием пользователя и управлением регионом.
* **AboutView** — информация о приложении и версии.
* **ArticlesByCategoryView** — статьи по конкретной категории.
* **ArticlesByTagView** — статьи по конкретному тегу.

#### Компоненты и секции:
* **ArticleCompactCard** — компактная карточка статьи с изображением, категорией, рейтингом, тегами.
* **CategorySection** — горизонтальная секция статей по категории.
* **FavoritesSection** — секция избранных статей на главном экране.
* **RecentlyReadSection** — секция недавно прочитанных статей.
* **AllArticlesSection** — секция всех статей.
* **UsefulToolsSection** — секция полезных инструментов: карта, PDF, случайная статья.

---

## 🚧 Разделы, требующие дополнения (файлы не предоставлены):

### 🧩 UIUtils
- `Theme.swift`
- `Animations.swift` 
- `CardStyle.swift`
- `CardImageStyle.swift`
- `CardSize.swift`
- `ProgressBar.swift`
- `ScaleOnTap.swift`
- `ShakeEffect.swift`
- `ShimmerEffect.swift`
- `RoundedCorner.swift`
- `Color+Hex.swift`
- `Environment+ScreenSize.swift`
- `LoadingView.swift`
- `Accessibility+Extensions.swift`

### 🧩 Views/Components
- `ArticleCardView.swift`
- `ArticleMetaView.swift`
- `FavoriteCard.swift`
- `LanguagePickerView.swift`
- `PDFViewer.swift`
- `ReadingProgressBar.swift`
- `StarRatingView.swift`
- `TagFilterView.swift`
- `TagsView.swift`
- `TextSizeSettingsPanel.swift`

### 🧩 Tests
- `InGermanyTests.swift`
- Моки: `MockArticlesRepository.swift`, `MockCategoriesRepository.swift`, `MockDataService.swift`
- Тесты моделей: `ArticleTests.swift`, `CategoryTests.swift`, `LocationTests.swift`
- UI тесты: `AppUITests.swift`
- Ресурсы: `sample_articles.json`, `sample_categories.json`

### 📝 Документация для Roadmap
- `CHANGELOG.md`
- `README.md` 
- `next_steps.md`
- `ARCHITECTURE_ISSUES.md`
- `di_refactoring_progress.md`

---

## 🏷️ 5. Версии и ветки разработки

* Текущая версия: **v1.x.x**
* Основная ветка: `main`
* Рабочие ветки: `feature/*`, `fix/*`, `perf/*`, `docs/*`
* CI/CD: ручные скрипты (`release.sh`, `update_project_tree.sh`, `check_di_violations.sh`)

---

> 📝 **Примечание**: Этот файл содержит только информацию из предоставленных исходных файлов. Разделы, отмеченные как "требующие дополнения", будут заполнены после получения соответствующих файлов в следующей сессии.
```
