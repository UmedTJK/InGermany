//
//  AI_CONTEXT2.md
//  InGermany
//
//  Created by SUM TJK on 19.09.25.
//


🧠 AI_CONTEXT.md
📌 ОБЩАЯ ИНФОРМАЦИЯ О ПРОЕКТЕ
Название: InGermany
Разработчик: Umed Sabzaev
Версия: v1.5.2-current
Дата актуализации: 19.09.2025
Репозиторий: https://github.com/UmedTJK/InGermany
Цель: Мультиязычное офлайн iOS-приложение-путеводитель для мигрантов, студентов и новых жителей Германии.
Ключевые особенности:
•    📚 Структурированные статьи и категории
•    🗺️ Интерактивная карта локаций
•    ⭐ Система избранного и рейтингов
•    🔍 Поиск с фильтрацией по тегам и категориям
•    📄 Поддержка PDF-документов
•    🌍 Мультиязычность (RU/EN/DE/TJ)
•    🎨 Поддержка темной темы
•    📊 Аналитика чтения

⚙️ ТЕХНОЛОГИЧЕСКИЙ СТЕК
Основные технологии:
•    SwiftUI + MVVM архитектура
•    iOS 17+ (минимальная версия)
•    @AppStorage для хранения настроек
•    @ObservableObject / @EnvironmentObject для управления состоянием
•    UserDefaults для persistent data
•    Local JSON files для статей
Ограничения:
•    ❌ Избегать deprecated iOS 16 API
•    ❌ Нет внешних зависимостей (кроме системных фреймворков)
•    ❌ Нет сетевых запросов (полностью офлайн)

**Поддерживаемые функции iOS:**
- Dark Mode поддержка
- ShareLink (нативный SwiftUI) и кастомный UIActivityViewController
- NavigationStack
- SwiftUI Animations


### 🗂️ СТРУКТУРА ПРОЕКТА (ДЕТАЛЬНАЯ)


InGermany/
├── 📁 Core/                          # Основные файлы приложения
│   ├── InGermanyApp.swift            # Точка входа, инициализация менеджеров
│   └── ContentView.swift             # Главный TabView с 5 вкладками
│
├── 📁 Views/                         # Все экраны приложения
│   ├── HomeView.swift                # Домашний экран (полностью переработан)
│   ├── ArticleDetailView.swift       # Детальный просмотр статьи
│   ├── SearchView.swift              # Поиск с фильтрами
│   ├── FavoritesView.swift           # Избранное + поиск + фильтры
│   ├── CategoriesView.swift          # Список категорий
│   ├── ArticlesByCategoryView.swift  # Статьи по категории
│   ├── ArticlesByTagView.swift       # Статьи по тегу
│   ├── MapView.swift                 # Карта с локациями
│   ├── SettingsView.swift            # Настройки языка и темы
│   ├── AboutView.swift               # О приложении
│   │
│   └── 📁 Components/                # Переиспользуемые UI компоненты
│       ├── ArticleCardView.swift     # Карточка статьи для сеток
│       ├── ArticleRow.swift          # Строка статьи для списков
│       ├── FavoriteCard.swift        # Карточка для горизонтального скролла
│       ├── PDFViewer.swift           # Вьювер PDF документов
│       ├── ReadingProgressBar.swift  # Индикатор прогресса чтения
│       └── TagFilterView.swift       # Компонент фильтрации по тегам
│
├── 📁 Models/                        # Модели данных
│   ├── Article.swift                 # Модель статьи
│   ├── Category.swift                # Модель категории
│   ├── Location.swift                # Модель локации
│   ├── RatingManager.swift           # Менеджер рейтингов (singleton)
│   └── ReadingHistoryManager.swift   # Менеджер истории чтения (новый)
│
├── 📁 Services/                      # Сервисы работы с данными
│   ├── DataService.swift             # Загрузка данных из JSON
│   ├── AuthService.swift             # Сервис аутентификации (в разработке)
│   └── ShareService.swift            # Сервис расшаривания контента
│
├── 📁 Utils/                         # Вспомогательные утилиты
│   ├── LocalizationManager.swift     # Управление локализацией
│   ├── CategoryManager.swift         # Доступ к категориям по ID
│   ├── ReadingTimeCalculator.swift   # Калькулятор времени чтения
│   ├── ExportToPDF.swift             # Экспорт контента в PDF
│   ├── ProgressBar.swift             # Компонент прогресс-бара
│   ├── Animations.swift              # Кастомные анимации
│   └── Theme.swift                   # Тема и цвета приложения
│
├── 📁 Resources/                     # Ресурсы приложения
│   ├── articles.json                 # Данные статей (локализованные)
│   ├── categories.json               # Данные категорий
│   ├── locations.json                # Данные локаций для карты
│   ├── Test_Document.pdf             # Тестовый PDF документ
│   └── 📁 Screenshots/               # Скриншоты приложения
│       ├── home.png
│       ├── article.png
│       ├── categories.png
│       ├── favorites.png
│       ├── search.png
│       └── settings.png
│
└── 📁 Supporting Files/              # Документация и вспомогательные файлы
    ├── PROJECT_STRUCTURE.md
    ├── AI_CONTEXT.md
    └── Git_Mini_Guide.md




### 🛠️ СЕРВИСЫ И МЕНЕДЖЕРЫ (ДЕТАЛИ)

#### DataService

class DataService {
    // Основные методы
    func loadArticles() -> [Article]
    func loadCategories() -> [Category]
    func loadLocations() -> [Location]
    
    // Вспомогательные методы
    func getArticles(for categoryId: String) -> [Article]
    func getArticles(with tag: String) -> [Article]
    func getArticle(by id: String) -> Article?
}

#### FavoritesManager

class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []
    
    // Основные методы
    func toggleFavorite(article: Article)
    func isFavorite(article: Article) -> Bool
    func favoriteArticles(from articles: [Article]) -> [Article]
    
    // Новые методы
    func getFavoritesCount() -> Int
    func clearFavorites()
    
    // Хранение в UserDefaults через JSON encoding
    private func saveFavorites()
    private func loadFavorites()
}

#### RatingManager (Singleton)

class RatingManager {
    static let shared = RatingManager()
    private init() {}
    
    func rating(for articleId: String) -> Int
    func setRating(_ rating: Int, for articleId: String)
    func getAverageRating() -> Double
    func getRatedArticlesCount() -> Int
}

#### ReadingHistoryManager (Singleton, ObservableObject)

class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()
    private init() {}
    
    // Модель данных для записи истории
    struct ReadingHistoryEntry: Identifiable, Codable {
        let id: String
        let articleId: String
        let readAt: Date
        let readingTimeSeconds: TimeInterval
    }
    
    // Основные методы
    func addReadingEntry(articleId: String, readingTime: TimeInterval) // Сохраняет только если readingTime >= 10 сек
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article]
    func isRead(_ articleId: String) -> Bool
    func lastReadDate(for articleId: String) -> Date?
    func clearHistory() // Очищает всю историю чтения
    
    // Статистика
    var totalReadingTimeMinutes: Int
    var totalArticlesRead: Int
    
    // Детали реализации
    private let maxHistoryEntries = 100 // Ограничение размера истории
    // Данные сохраняются в @AppStorage("readingHistory") в закодированном виде (Data)
}

#### ReadingTracker (реальное время)

class ReadingTracker: ObservableObject {
    func startReading(articleId: String)
    func finishReading()
    var currentReadingTime: TimeInterval
}

#### ReadingProgressTracker (скролл)

// Используется в ArticleView
Text(article.content)
    .trackReadingProgress(progressTracker)

ReadingProgressBar(progress: progressTracker.scrollProgress)




📊 МОДЕЛИ ДАННЫХ (полная спецификация)
Article
struct Article: Identifiable, Codable, Hashable {
    let id: String
    let title: [String: String]       // ["ru": "...", "en": "...", "de": "...", "tj": "..."]
    let content: [String: String]     // Мультиязычный контент
    let categoryId: String
    let tags: [String]
    let pdfFileName: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    // Методы локализации:
    func localizedTitle(for language: String) -> String
    func localizedContent(for language: String) -> String
    func formattedReadingTime(for language: String) -> String
}
Category
struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]  // Локализованные названия
    let icon: String            // SF Symbol
    
    func localizedName(for language: String) -> String
}
Location
struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D
}

💡 ВАЖНЫЕ ОСОБЕННОСТИ ДЛЯ AI-АССИСТЕНТОВ
🎯 Архитектурные паттерны и соглашения
Все View должны использовать:
struct MyView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var readingHistoryManager: ReadingHistoryManager
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @Environment(\.colorScheme) var colorScheme
    
    // Обязательный параметр для навигации
    let allArticles: [Article]
}
Навигационные параметры (единый стандарт):
// ArticleDetailView
ArticleDetailView(
    article: Article,
    allArticles: [Article],
    favoritesManager: FavoritesManager
)

// ArticlesByCategoryView
ArticlesByCategoryView(
    category: Category,
    articles: [Article],
    favoritesManager: FavoritesManager
)

// ArticlesByTagView
ArticlesByTagView(
    tag: String,
    articles: [Article],
    favoritesManager: FavoritesManager
)

📊 МЕНЕДЖЕРЫ И СОСТОЯНИЕ
Обязательные зависимости для View:
@ObservedObject var favoritesManager: FavoritesManager
let articles: [Article]
let categories: [Category]? // опционально

@AppStorage("isDarkMode") private var isDarkMode: Bool
@AppStorage("selectedLanguage") private var selectedLanguage: String

🎯 ТОЧНЫЕ ПАРАМЕТРЫ ДЛЯ КАЖДОГО ЭКРАНА
HomeView
HomeView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
CategoriesView
CategoriesView(
    categories: [Category],
    articles: [Article],
    favoritesManager: FavoritesManager
)
SearchView
SearchView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
FavoritesView
FavoritesView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
SettingsView
SettingsView()  // Настройки через AppStorage

🏗️ АРХИТЕКТУРА HOMEVIEW
Обязательные зависимости HomeView:
struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
    let articles: [Article]
    
    private let allCategories = CategoryManager.shared.allCategories()
}

📊 СЕКЦИИ HOMEVIEW
1. Useful Tools Section
NavigationLink { MapView() }
Button(action: { /* random article logic */ })
2. Recently Read Section
let recentArticles = readingHistoryManager.recentlyReadArticles(from: articles, limit: 5)
// Использует RecentArticleCard
3. Favorites Section
let favorites = favoritesManager.favoriteArticles(from: articles)
// Использует FavoriteCard
4. Category Sections
ForEach(allCategories) { category in
    if let categoryArticles = articlesByCategory[category.id] {
        categorySection(category: category, articles: categoryArticles)
    }
}
5. All Articles Section
// Полный список статей с ArticleRowWithReadingInfo


🎯 НОВЫЕ КОМПОНЕНТЫ (реальные из кода)
RecentArticleCard
struct RecentArticleCard: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let lastReadDate: Date?
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}
ArticleRowWithReadingInfo
struct ArticleRowWithReadingInfo: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let isRead: Bool
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}
CategoryArticleCard
struct CategoryArticleCard: View {
    let article: Article
    let category: Category
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}

### 📱 ЭКРАНЫ (VIEWS) - ДЕТАЛИ

**ArticleDetailView** - Упрощенная версия просмотрщика статьи
• Используется в контексте списков (например, ArticlesByTagView)
• Не включает трекинг чтения и расширенную аналитику
• Параметры: article, favoritesManager, selectedLanguage

**ArticleView** - Полная версия просмотрщика статьи
• Основной экран для чтения из HomeView, FavoritesView
• Включает всю систему аналитики: трекинг времени, прогресс, рейтинг
• Параметры: article, allArticles, favoritesManager

⚡ КРИТИЧЕСКИ ВАЖНЫЕ СВЯЗИ
Навигация к ArticleView
NavigationLink(
    destination: ArticleView(
        article: article,
        allArticles: articles,
        favoritesManager: favoritesManager
    )
) {
    // Компонент карточки
}
Работа с ReadingHistoryManager
readingHistoryManager.isRead(article.id)
readingHistoryManager.lastReadDate(for: article.id)
readingHistoryManager.recentlyReadArticles(from: articles, limit: 5)

🎨 СТИЛИ И АНИМАЦИИ
Card Style
.cardStyle()
.shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
.cornerRadius(12)
Button Styles
.buttonStyle(AppleCardButtonStyle())

🌍 СИСТЕМА ЛОКАЛИЗАЦИИ (актуальная версия)
Пример реализации
private func getTranslation(key: String, language: String) -> String {
    let translations: [String: [String: String]] = [
        "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
        "Карта локаций": ["ru": "Карта локаций", "en": "Location Map", "de": "Standortkarte", "tj": "Харитаи ҷойҳо"],
        "Случайная статья": ["ru": "Случайная статья", "en": "Random Article", "de": "Zufälliger Artikel", "tj": "Мақолаи тасодуфӣ"]
    ]
    return translations[key]?[language] ?? key
}
Принципы:
•    Поддерживаемые языки: ru, en, de, tj
•    Fallback: выбранный → en → первый доступный → ключ
•    Локализация встроена в каждый View (децентрализованно)

📊 МОДЕЛЬ CATEGORY (встроенный метод)
struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]
    let icon: String
    
    func localizedName(for language: String) -> String {
        name[language] ?? name["en"] ?? name.values.first ?? "No name"
    }
}

🚨 ВАЖНЫЕ ОГРАНИЧЕНИЯ
1.    FavoritesManager не singleton — создаётся в ContentView.
2.    Локализация децентрализована — ключи дублируются между View.
3.    ReadingProgressTracker требует .trackReadingProgress модификатора.

**💡 ПРИНЦИПЫ ХРАНЕНИЯ ДАННЫХ (ДОПОЛНЕНИЕ)**

1.  **@AppStorage для сложных данных:** Для хранения структур данных (массивов, словарей) в `UserDefaults` используется механизм кодирования в `Data` (JSONEncoder/Decoder) с последующим сохранением через `@AppStorage`.
    - Пример: `ReadingHistoryManager` использует `@AppStorage("readingHistory") private var storedHistory: Data = Data()`

2.  **Оптимизация памяти:** Менеджеры могут использовать in-memory кэш (например, `ratings: [String: Int]` в `RatingManager`) для производительности, синхронизируя его с `UserDefaults`.
🎯 ARTICLEVIEW ARCHITECTURE
Обязательные параметры
struct ArticleView: View {
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    
    @ObservedObject var ratingManager = RatingManager.shared
    @StateObject private var readingTracker = ReadingTracker()
    @StateObject private var progressTracker = ReadingProgressTracker()
}
Ключевые функции
// Отслеживание чтения
.onAppear { readingTracker.startReading(articleId: article.id) }
.onDisappear { readingTracker.finishReading() }

// Прогресс скролла
Text(article.content).trackReadingProgress(progressTracker)

// Навигация к началу
proxy.scrollTo("articleTop", anchor: .top)

// Похожие статьи
private var relatedArticles: [Article] {
    allArticles
        .filter { $0.categoryId == article.categoryId && $0.id != article.id }
        .prefix(3)
        .map { $0 }
}

⚡ ТЕХНИЧЕСКИЕ ДЕТАЛИ
Haptic Feedback
HapticFeedback.medium()  // при добавлении в избранное
HapticFeedback.light()   // при прокрутке к началу
ScrollViewReader
ScrollViewReader { proxy in
    ScrollView {
        // Контент с .id("articleTop")
    }
    .toolbar {
        Button { proxy.scrollTo("articleTop") }
    }
}
ShareLink
ShareLink(
    item: "\(title)\n\n\(content)",
    subject: Text(title),
    message: Text("Поделитесь этой статьёй")
)

🎨 UI КОМПОНЕНТЫ
Progress Bar
ReadingProgressBar(
    progress: progressTracker.scrollProgress,
    height: 6,
    foregroundColor: progressTracker.isReading ? .green : .blue
)
Article Tools
ToolbarItem(placement: .navigationBarTrailing) {
    Button { /* toggle favorite */ }
    Button { /* scroll to top */ }
}

🔍 СИСТЕМА ПОИСКА
SearchView логика
private var filteredArticles: [Article] {
    var results = articles
    
    if let tag = selectedTag {
        results = results.filter { $0.tags.contains(tag) }
    }
    
    if !searchText.isEmpty {
        results = results.filter { article in
            article.localizedTitle(for: selectedLanguage).contains(searchText) ||
            article.localizedContent(for: selectedLanguage).contains(searchText) ||
            CategoryManager.shared.category(for: article.categoryId)?
                .localizedName(for: selectedLanguage).contains(searchText) ?? false
        }
    }
    return results
}
FavoritesView фильтрация
private var filteredFavoriteArticles: [Article] {
    let favorites = favoritesManager.favoriteArticles(from: articles)
    
    var filtered = favorites
    if let selectedCategory = selectedCategory {
        filtered = filtered.filter { $0.categoryId == selectedCategory }
    }
    if !searchText.isEmpty {
        filtered = filtered.filter { $0.title[selectedLanguage]?.contains(searchText) ?? false }
    }
    return filtered
}

🗺️ СИСТЕМА КАРТЫ (MapView)
struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    let locations: [Location] = DataService.shared.loadLocations()
    
    @available(iOS 17.0, *)
    var body: some View {
        Map(initialPosition: .region(region))
    }
    
    // Альтернатива для iOS < 17
    var legacyBody: some View {
        Map(coordinateRegion: $region, annotationItems: locations)
    }
    
    Button { region.center = locationManager.userLocation }
}

🎨 ДИЗАЙН (Theme.swift)
struct Theme {
    static let primaryBlue = Color.blue
    static let secondaryGray = Color.secondary
    static let backgroundCard = Color(.systemBackground)
    
    static let cardGradient = LinearGradient(...)
    static let favoriteCardGradient = LinearGradient(...)
    
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    
    static let cardShadow = Shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
}


### 📝 JSON СТРУКТУРА ДАННЫХ

**Пример статьи:**
{
  "id": "177b5cc8-9de1-4bd4-9739-9e1ec090f904",
  "title": {
    "ru": "Финансы — пример 1",
    "en": "Финансы - Example 1",
    "de": "Финансы - Beispiel 1",
    "tj": "Финансы — намунаи 1"
  },
  "content": {
    "ru": "Это пример содержимого статьи №1 в категории Финансы.",
    "en": "This is example content for article #1 in category Finance.",
    "de": "Dies ist ein Beispielinhalt für Artikel #1 in der Kategorie Finanzen.",
    "tj": "Ин мазмуни намунавии мақолаи №1 дар категорияи Молия аст."
  },
  "categoryId": "11111111-1111-1111-1111-aaaaaaaaaaaa",
  "tags": [
    "finance",
    "финансы",
    "пример"
  ],
  "createdAt": "2025-09-18T17:25:26.466061Z",
  "updatedAt": "2025-09-18T17:25:26.466061Z"
}




* 3415f56 (HEAD -> main, origin/main) feat: добавлены свайп-действия и контекстное меню для избранного
* 71f0d74 Создал актуальный AI_CONTEXT2.md
* acf0169 Обновил файл AI_CONTEXT.md
* ad3634e chore: remove Firebase integration and config files
* d54a1a2 📊 Чтение и аналитика | HomeView, ReadingTracker, Статистика
* a48f118 refactor: unify selectedLanguage access via AppStorage in all Views
* 1a4c296 (tag: v1.4.4-home-horizontal) feat: полностью переработан HomeView с горизонтальным скроллом избранного
* b60f3a3 fix: убрано дублирование поля поиска в FavoritesView
* d00a513 feat: добавлен поиск в избранном
* 66fa290 (tag: v1.4.4-favorites-filter) feat: добавлен фильтр по категориям в FavoritesView
* a4404b2 (tag: v1.5.1-firebase-setup) chore(firebase): add initial firebase configuration
* 3829c43 (tag: v1.5.0-random-article) feat(home): add random article button with modern navigation
* 575da1d (tag: v1.4.3-docs) docs: обновлён AI_CONTEXT.md — актуализирована структура, типы данных и советы
* e83910e (tag: v1.4.2-stable, tag: v1.4.2-related) feat: добавлена кнопка «Поделиться статьёй» в ArticleView с использованием ShareLink
* 03eacca (tag: v1.4.0-rating) feat: добавлен рейтинг статей (оценка 1–5 звёзд); реализован RatingManager с сохранением в UserDefaults; добавлен RatingView
* 1bf2f2c (tag: v1.3.2-stable, tag: v1.3.2-before-rating) fix: восстановлена стабильная версия после теста ArticleDetailView; удалён аргумент allArticles, возвращён ArticleView из v1.3.0
* 9c3b883 (tag: v1.3.1, stable-v1.0.0) feat: MapView с JSON-локациями, поддержкой iOS 17 и кнопкой 'Моё местоположение'
* 42fc567 (tag: v1.3.0) feat: добавлен экран карты и ссылка на него в HomeView
* 93708ba feat: добавлена ссылка на MapView в начале HomeView
* d52f166 (tag: v1.2.0) feat: добавлена поддержка PDF-документов в статьях
* facd40f feat: миниатюра логотипа слева от названия статьи в списке
* fa0dcbe fix: исправлены аргументы вызова FavoritesManager в ArticleDetailView
* 0e75961 (tag: v1.1.0) feat: добавлена фильтрация статей по тегам в SearchView
* 965fb09 feat: добавлен экран 'О проекте' + улучшения в SettingsView
* 33bfcb2 (tag: v1.0.0, origin/stable-v1.0.0, origin/restore-recommendation) docs: сохранена эталонная версия с избранным, рекомендациями, тегами и темной темой
* 881adc5 feat: рекомендации по теме — добавлен блок 'Материалы по данной теме' в ArticleDetailView
* f2f4105 docs: обновлён README — добавлены реализованные фичи (тёмная тема, избранное, поделиться, навигация по тегам)
* ac28f15 feat: добавлена навигация по тегам в ArticleDetailView и новый экран ArticlesByTagView
* 5ace0f0 Исправлен вызов FavoritesView и переходы: унифицирован переход к ArticleDetailView
о все View
* 5c3176a Добавил техническое описание проекта (PROJECT_STRUCTURE.md)
* 827d95f Добавил мини-шпаргалку по Git
* fca6de1 Переименовал 📄 Project Brief.docx → Project_Brief.docx
* 11a0a18 Вернул файлы проекта, исправил .gitignore
* ebbf329 Применил финальный .gitignore
* 83dcaa3 Очистил репозиторий от .DS_Store и xcuserdata
очая версия проекта
* f8a6842 fix: исправлены ошибки типов данных
* 33ec46e Добавил анимации в ArticleRow
* 3450183 обновил UI
* 2de4309 Add screenshots section with grid layout
e
* df924ba Replace README with extended professional documentation
* 55574f5 Update README with full project documentation
* 99439e0 Add .gitignore and README
* be6c90c Initial commit


🚀 ROADMAP
Short-term (v1.6.0)
•    📊 Аналитика чтения
•    📄 Экспорт PDF
•    🎭 Анимации
•    ⚡ Оптимизация
Medium-term (v1.7.0)
•    ☁️ Supabase
•    🔔 Push-уведомления
•    📱 Виджеты
•    🖼️ Кэширование изображений
Long-term (v2.0.0)
•    🔐 Авторизация
•    ☁️ Синхронизация
•    💬 Комментарии
•    🤖 AI-рекомендации


Вот список "маленьких фич", отсортированных по простоте реализации и ценности для пользователя:

### 🎯 Быстрые победы (Можно добавить почти сразу)

1.  **"Поделиться статьей" в ArticleRow/ArticleCard**
    Добавить кнопку ShareLink прямо в карточки статей в списках, чтобы делиться, не открывая статью полностью.
    ```swift
    // В ArticleRow.swift и т.д.
    .contextMenu {
        ShareLink(item: article.localizedTitle(for: selectedLanguage)) {
            Label("Поделиться", systemImage: "square.and.arrow.up")
        }
        // ... остальное меню
    }
    ```

2.  **Swipe Actions в списках статей**
    Добавить свайпы для быстрого добавления/удаления из избранного.
    ```swift
    .swipeActions(edge: .leading) {
        Button {
            favoritesManager.toggleFavorite(article: article)
        } label: {
            Label("Избранное", systemImage: favoritesManager.isFavorite(article: article) ? "heart.slash" : "heart")
        }
        .tint(.accentColor)
    }
    ```

3.  **Быстрая навигация по тегам**
    В `ArticleDetailView` сделать теги кликабельными. Тап по тегу должен вести на `ArticlesByTagView`.
    ```swift
    // В ArticleDetailView
    ScrollView(.horizontal) {
        HStack {
            ForEach(article.tags, id: \.self) { tag in
                NavigationLink(destination: ArticlesByTagView(tag: tag, articles: allArticles, favoritesManager: favoritesManager)) {
                    Text("#\(tag)")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.gray.opacity(0.2)))
                }
            }
        }
    }
    ```

4.  **Индикатор "Новое" или "Непрочитанное"**
    В `ArticleRow` или `ArticleCard` добавить небольшую точку или бейдж для статей, которые еще ни разу не открывались (`!readingHistoryManager.isRead(article.id)`).

5.  **Pull-to-Refresh на главном экране**
    Добавить жестанцию "потянуть чтобы обновить" на `HomeView`, хотя данные локальные. Это может сбрасывать кэш менеджеров или просто обеспечивать психологический комфорт пользователю.
    ```swift
    .refreshable {
        // Можно сбросить/перезагрузить какие-нибудь легкие данные
        HapticFeedback.light()
    }
    ```








### 💡 Фичи чуть сложнее (Требуют немного больше работы)

6.  **Поиск по тегам в SearchView**
    Добавить в `SearchView` не только фильтр по одному тегу, но и секцию "Популярные теги" или поисковые подсказки по тегам.

7.  **Динамический размер текста в ArticleView**
    Добавить панель инструментов или меню настроек в `ArticleView` для изменения размера шрифта. Сохранять выбор пользователя в `@AppStorage`.

8.  **Копирование фрагмента текста**
    В `ArticleView` добавить возможность долгого нажатия на абзац для его копирования через контекстное меню.

9.  **"Вам также может быть интересно" в конце статьи**
    Расширить логику `relatedArticles` в `ArticleView`, чтобы она учитывала не только категорию, но и общие теги, предлагая более релевантные статьи.

10. **Добавление кастомных ярлыков (Deep Links)**
    Добавить поддержку URL Schemes для глубоких ссылок, например: `ingermany://article/{id}` для открытия конкретной статьи извне.

11. **Виджеты для быстрого доступа**
    Не дожидаясь v1.7.0, можно добавить простейший виджет на экран "Сегодня" (Today Widget), который показывает, например, последнюю прочитанную статью или случайную статью дня.

12. **Офлайн-доступ к PDF**
    Реализовать кэширование открытых PDF-файлов (если они не встроены в бандл) для последующего офлайн-доступа, если в будущем появятся PDF извне.

13. **Система закладок внутри статьи**
    Позволить пользователю ставить закладки на определенные места в длинной статье. Данные можно хранить в том же `ReadingHistoryManager`.

14. **Темы/акцентные цвета**
    Расширить `Theme.swift` и `SettingsView`, позволив пользователю выбирать акцентный цвет (синий, зеленый, оранжевый) помимо светлой/темной темы.

15. **Анимация Lottie вместо SF Symbols**
    Добавить поддержку простых Lottie-анимаций для иконок "пустое состояние" в `FavoritesView` или `SearchView`, чтобы сделать интерфейс живее.

### 🧠 Самые крутые "маленькие" фичи

16. **"Случайная статья из категории"**
    В `CategoriesView` или на главном экране в секции категории добавить кнопку, которая ведет не на список статей категории, а сразу на одну, случайную статью из этой категории.

17. **Режим "Только текст" / Reader Mode**
    В `ArticleView` добавить кнопку, которая убирает всю лишнюю разметку и оставляет только чистый текст для максимальной концентрации.

18. **Таймер чтения**
    В настройках или прямо в `ArticleView` добавить таймер (например, "читать еще 10 минут"), который по истечении времени подаст мягкий сигнал.

19. **Интеграция с Картами (Apple/Google Maps)**
    В `MapView` для каждой локации добавить кнопку "Построить маршрут", которая открывает системное приложение Карт с проложенным маршрутом до выбранной точки.

20. **Встроенный быстрый словарь**
    Реализовать возможность выделять слово в статье и смотреть его перевод через системный `Lookup` контроллер.


⚡ ВАЖНО ДЛЯ AI-АССИСТЕНТОВ
1.    Все View должны получать favoritesManager и articles.
2.    Навигация всегда передаёт allArticles в ArticleView.
3.    Не использовать UserDefaults напрямую — только через менеджеры.
4.    Все тексты — через локализацию.
5.    Код должен быть SwiftLint-совместимым и iOS 17+.

📞 КОНТАКТЫ
Разработчик: Umed Sabzaev
Email: umed@example.com
GitHub: https://github.com/UmedTJK

