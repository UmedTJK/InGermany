Отлично! Приступаю к обновлению AI_CONTEXT.md на основе всех предоставленных файлов. Создам полный обновленный файл с добавлением разделов UIUtils и Views/Components.

```markdown
# AI_CONTEXT.md - InGermany Project

## 📖 ОБЗОР ПРОЕКТА
**InGermany** - iOS-приложение на SwiftUI для мигрантов в Германии, содержащее статьи и руководства по жизни, работе, документам и адаптации.

## 🏗️ АРХИТЕКТУРА
Чистая архитектура с разделением на слои:

### 📱 CORE LAYER
**AppContainer** - главный DI-контейнер, инициализирующий все зависимости
- Создает и управляет всеми менеджерами, сервисами, репозиториями
- Реализует протоколы: ArticlesRepositoryProtocol, CategoriesRepositoryProtocol, FavoritesManagerProtocol, RatingManagerProtocol, LocalizationManagerProtocol
- Предоставляет фабричные методы для создания ViewModels

### 🧠 MANAGERS LAYER
**FavoritesManager** - управление избранными статьями
- `toggleFavorite(_ article: Article)` - переключение статуса избранного
- `isFavorite(_ article: Article) -> Bool` - проверка статуса
- `getFavorites() -> [Article]` - получение списка избранных
- Использует UserDefaults для хранения

**RatingManager** - управление рейтингами статей
- `setRating(_ value: Int, for articleId: String)` - установка рейтинга
- `getRating(for articleId: String) -> Int` - получение рейтинга
- `getAllRatings() -> [String: Int]` - все рейтинги
- Использует UserDefaults для хранения

**LocalizationManager** - управление локализацией
- `getTranslation(key: String, language: String) -> String` - получение перевода
- `availableLanguages() -> [String]` - список доступных языков
- Использует JSON-файлы для хранения переводов

### 🔧 SERVICES LAYER
**ArticleFormatter** - форматирование данных статей
- `readingTime(_ article: Article, for language: String) -> Int` - расчет времени чтения
- `formattedCreatedDate(_ article: Article, for language: String) -> String` - форматирование даты создания
- `formattedUpdatedDate(_ article: Article, for language: String) -> String` - форматирование даты обновления

**PDFExportService** - экспорт статей в PDF
- `exportToPDF(_ article: Article, language: String) -> URL?` - экспорт статьи
- `generatePDFContent(_ article: Article, language: String) -> Data` - генерация содержимого

### ArticleRenderer
- **Файл:** `Services/ArticleRenderer.swift`
- **Описание:** Универсальный рендерер для отображения статей в виде секций.  
- **Основные возможности:**
  - Поддержка разных типов блоков: `paragraph`, `info`, `warning`, `tip`, `quote`, `checklist`, `faq`, `links`
  - Гибкое оформление статей через вложенные вью-компоненты
  - Рендеринг из структуры `[ArticleSection]`

### Services/articles
- **Папка:** `Services/articles`
- **Содержимое:** JSON-файлы со статьями
- **Пример:** `burgeramt_registration.json`
- **Назначение:** Хранение и загрузка статей в формате JSON, которые могут использоваться в приложении для демонстрации работы `ArticleRenderer`


### 💾 REPOSITORIES LAYER
**ArticlesRepository** - работа с данными статей
- `getAllArticles() -> [Article]` - все статьи
- `getArticle(by id: String) -> Article?` - статья по ID
- `getArticles(by categoryId: String) -> [Article]` - статьи по категории
- `getRecentArticles(limit: Int) -> [Article]` - недавние статьи
- Загружает данные из JSON-файлов

**CategoriesRepository** - работа с категориями
- `getAllCategories() -> [Category]` - все категории
- `category(by id: String) -> Category?` - категория по ID
- Загружает данные из JSON-файлов

### 📦 MODELS LAYER
**Article** - модель статьи
- Свойства: `id`, `categoryId`, `image`, `titleRu`, `titleEn`, `contentRu`, `contentEn`, `createdAt`, `updatedAt`, `isNew`, `isUpdatedRecently`
- Методы: `localizedTitle(for:)`, `localizedContent(for:)`

**Category** - модель категории
- Свойства: `id`, `nameRu`, `nameEn`, `colorHex`, `systemImage`

### ReadingHistoryEntry
- **Файл:** `Models/ReadingHistoryEntry.swift`
- **Описание:** Описывает отдельный факт чтения статьи пользователем.
- **Поля:**
  - `id: UUID` — уникальный идентификатор записи
  - `articleId: String` — ID статьи
  - `readAt: Date` — дата и время прочтения
  - `readingTimeSeconds: TimeInterval` — длительность чтения в секундах

### ReadingStats
- **Файл:** `Models/ReadingStats.swift`
- **Описание:** Агрегированная статистика чтения.
- **Поля:**
  - `totalReadCount: Int` — общее количество прочитанных статей
  - `totalReadingTimeSeconds: TimeInterval` — общее время чтения (в секундах)
  - `lastReadDate: Date?` — дата последнего чтения
- **Методы:**
  - `init(from history: [ReadingHistoryEntry])` — формирование статистики на основе истории
  - `static let empty` — пустая статистика


### 🎨 VIEWMODELS LAYER
**ArticleRowViewModel** - ViewModel для строки статьи
- `@Published var title: String`, `@Published var subtitle: String`, `@Published var metaInfo: String`, `@Published var rating: Int`, `@Published var isFavorite: Bool`, `@Published var imageName: String?`
- Методы: `toggleFavorite()`, `setRating(_:)`

**ArticlesListViewModel** - ViewModel для списка статей
- `@Published var articles: [Article]`, `@Published var selectedCategory: String?`, `@Published var searchText: String`, `@Published var isLoading: Bool`
- Методы: `loadArticles()`, `filteredArticles() -> [Article]`

**FavoritesViewModel** - ViewModel для избранного
- `@Published var favoriteArticles: [Article]`, `@Published var searchText: String`, `@Published var selectedCategory: String?`
- Методы: `loadFavorites()`, `filteredFavorites() -> [Article]`

**SettingsViewModel** - ViewModel для настроек
- `@Published var selectedLanguage: String`, `@Published var selectedCardStyle: CardStyle`, `@Published var selectedImageStyle: CardImageStyle`, `@Published var textSize: Double`
- Методы: `resetAllData()`, `exportData()`

### 👀 VIEWS LAYER
**Основные экраны:**
- `ContentView` - главный экран с TabView
- `ArticlesListView` - список статей
- `ArticleDetailView` - детальный просмотр статьи
- `FavoritesView` - избранные статьи
- `SettingsView` - настройки приложения

## 🎨 UIUTILS

### Theme
**Theme** - структура с константами стилей приложения:
- **Colors**: `primaryBlue`, `secondaryGray`, `backgroundCard`, `backgroundMain`
- **Gradients**: `cardGradient`, `favoriteCardGradient`
- **Spacing**: `cardPadding`, `cardCornerRadius`, `smallPadding`, `mediumPadding`, `largePadding`
- **Shadows**: `cardShadow`, `lightShadow`

**Shadow** - структура для определения стилей теней

**Расширения View**:
- `sectionCardStyle()` - применяет стандартный стиль карточки

### Shapes & Effects
**RoundedCorner** - Shape для скругления определенных углов:
- `radius: CGFloat`, `corners: UIRectCorner`
- Расширение View: `cornerRadius(_ radius: CGFloat, corners: UIRectCorner)`

**Shake** - GeometryEffect для эффекта тряски:
- `amount: CGFloat`, `shakesPerUnit: Int`, `animatableData: CGFloat`

**ScaleOnTap** - ViewModifier для анимации уменьшения при нажатии:
- Использует `DragGesture` и `@GestureState`

**Shimmer** - ViewModifier для эффекта shimmer-анимации загрузки:
- Анимированный градиент с `LinearGradient` и `rotationEffect`

### Animations & Styles
**Animations** - расширения View для анимаций:
- `cardStyle()` - стандартный стиль карточки с тенью
- `lightCardStyle()` - легкий стиль карточки
- `scaleOnAppear()` - spring-анимация появления
- `pressAnimation()` - анимация нажатия
- `slideInAnimation(delay:)` - slide-in анимация с задержкой

**CardStyle** - enum визуальных стилей карточек:
- `standard`, `light`
- Расширение View: `applyCardStyle(_ style: CardStyle)`

**CardImageStyle** - enum стилей отображения изображений:
- `allCorners`, `bottomCorners`, `fullWidth`
- Локализованные названия через `localizedTitle`

### Utilities
**CardSize** - утилита для расчета размеров карточек:
- `width(for screenWidth: CGFloat) -> CGFloat`
- `height(for screenHeight: CGFloat, screenWidth: CGFloat) -> CGFloat`
- Адаптивные размеры для iPhone SE, обычных iPhone и iPad

**ReadingTimeCalculator** - утилита расчета времени чтения:
- `estimateReadingTime(for text: String, language: String, wordsPerMinute: Int = 200) -> Int`
- `formatReadingTime(_ minutes: Int, language: String) -> String`

**Color+Hex** - расширение Color для инициализации из HEX:
- `init?(hex: String)`

**Environment+ScreenSize** - EnvironmentValue для размера экрана:
- `screenSize: CGSize`

### Components
**LoadingView** - полноэкранный оверлей загрузки:
- `message: String?`
- `ProgressView` с кастомным стилем

**ProgressBar** - компонент прогресс-бара:
- `value: CGFloat` (0.0 до 1.0)
- Анимированное заполнение

**Accessibility+Extensions** - расширения для доступности:
- `a11yLabel(_ text: String)`
- `a11yHint(_ text: String)`
- `a11yAddTraits(_ traits: AccessibilityTraits)`

## 🧩 VIEWS/COMPONENTS

### Article Components
**ArticleCardView** - карточка статьи:
- Отображает изображение, заголовок, рейтинг, краткое содержание
- Использует `StarRatingView` для отображения рейтинга
- Поддерживает локализацию через `@AppStorage`

**ArticleMetaView** - метаданные статьи:
- Категория с цветным индикатором
- Рейтинг (если > 0)
- Время чтения
- Даты публикации и обновления
- Бейджи "Новое" и "Обновлено"
- Использует `BadgeView` для бейджей

**ArticleRow** - строка статьи в списках:
- Изображение, заголовок, метаданные
- `StarRatingView` для рейтинга
- Кнопка избранного (сердечко)
- Использует `ArticleRowViewModel`

**FavoriteCard** - компактная карточка избранной статьи:
- Горизонтальная layout с изображением и текстом
- Используется в списках избранного

### Reusable Components
**Components** содержит несколько компонентов:
- **ToolCard**: карточка инструмента с иконкой и заголовком
- **RecentArticleCard**: карточка недавней статьи с изображением и текстом
- **EmptyFavoritesView**: экран-заглушка для пустых избранных
- **CategoryFilterButton**: кнопка фильтра категорий с состоянием выбора

**LanguagePickerView** - компонент выбора языка:
- `Binding var selectedLanguage: String`
- Поддерживает языки: ru, en, de, tj, fa, ar, uk с флагами
- Использует `MenuPickerStyle`

### ArticleBlockView
- **Файл:** `UIUtils/ArticleComponents/ArticleBlockView.swift`
- **Описание:** Универсальный блок для выделения текста в стиле информационного сообщения.
- **Поддерживаемые стили:** `.info`, `.warning`, `.tip`, `.quote`
- **Особенности:** цветной фон, иконки, рамки для лучшей читаемости текста.

### ChecklistCardView
- **Файл:** `UIUtils/ArticleComponents/ChecklistCardView.swift`
- **Описание:** Отображает список элементов с чекбоксами (выполнено/не выполнено).
- **Использование:** для пошаговых инструкций, списков задач в статьях.

### FAQBlockView
- **Файл:** `UIUtils/ArticleComponents/FAQBlockView.swift`
- **Описание:** Компонент «Вопрос — Ответ» для секций типа `faq`.
- **Особенности:** аккордеон-стиль раскрытия, удобен для длинных справочных материалов.

### DemoArticleView
- **Файл:** `Views/DemoArticleView.swift`
- **Описание:** Вспомогательный экран для тестирования рендеринга статей.
- **Использование:** разработка и отладка `ArticleRenderer` с тестовыми JSON-данными.


### Utility Components
**BadgeView** - универсальный компонент бейджа:
- `text: String`, `color: Color`
- Стилизованный текст с фоном

**StarRatingView** - компонент звездного рейтинга (предполагается из контекста)
**ReadingProgressBar** - компонент прогресса чтения (предполагается из контекста)
**TextSizeSettingsPanel** - панель настройки размера текста (предполагается из контекста)

## 🧪 ТЕСТИРОВАНИЕ
**НЕ ПРЕДОСТАВЛЕНО**

## 📋 ДОКУМЕНТАЦИЯ ДЛЯ ROADMAP
**НЕ ПРЕДОСТАВЛЕНО**

## 🔄 MIGRATION & REFACTORING
**НЕ ПРЕДОСТАВЛЕНО**

## 🎯 СЛЕДУЮЩИЕ ШАГИ
**НЕ ПРЕДОСТАВЛЕНО**


## 9. UI/UX Enhancements for Articles

С недавнего обновления проект поддерживает расширенное визуальное оформление статей.  
Основной рендеринг реализован через `ArticleRenderer`, который разбивает материал на секции (`ArticleSection`), каждая из которых может иметь свой тип отображения.

### Поддерживаемые секции
- **paragraph** — обычный текстовый абзац (`Text`).
- **info** — информационный блок (`ArticleBlockView` со стилем `.info`).
- **warning** — предупреждение (`ArticleBlockView` со стилем `.warning`).
- **tip** — совет, лайфхак (`ArticleBlockView` со стилем `.tip`).
- **quote** — цитата, визуально выделенная (`ArticleBlockView` со стилем `.quote`).
- **checklist** — список задач с чекбоксами (`ChecklistCardView`).
- **faq** — блок «Вопрос — Ответ» (`FAQBlockView`).
- **links** — список ссылок на другие статьи (с поддержкой `articleId`).

### Текущие возможности
- Визуально выделенные блоки (цветной фон, рамки, иконки).
- Чеклисты для пошаговых инструкций.
- FAQ-блоки для часто задаваемых вопросов.
- Кликабельные ссылки на другие статьи внутри приложения.
- Отладочный экран `DemoArticleView` для тестирования оформления.

### Планы развития
- Поддержка **inline-форматирования**: жирный/курсив/подсветка.
- Добавление **мультимедиа**: изображения, иконки, встроенное видео.
- Интерактивность: анимации, haptic feedback, свайпы.
- Автоматическая генерация **«связанных статей»** для кросс-навигации.
- Возможность вставки **таблиц и карточек** в контент.

`
