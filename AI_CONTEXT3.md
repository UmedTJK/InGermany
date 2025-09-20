//
//  AI_CONTEXT3.md
//  InGermany
//
//  Created by SUM TJK on 19.09.25.
//


## 🧠 AI_CONTEXT.md (Версия 2.0 - Полное объединение)

### 📌 ОБЩАЯ ИНФОРМАЦИЯ О ПРОЕКТЕ

**Название:** InGermany
**Разработчик:** Umed Sabzaev
**Версия:** v1.5.2-current
**Дата актуализации:** 19.09.2025
**Репозиторий:** https://github.com/UmedTJK/InGermany

**Цель:** Мультиязычное офлайн iOS-приложение-путеводитель для мигрантов, студентов и новых жителей Германии.

**Ключевые особенности:**
- 📚 Структурированные статьи и категории
- 🗺️ Интерактивная карта локаций
- ⭐ Система избранного и рейтингов
- 🔍 Поиск с фильтрацией по тегам и категориям
- 📄 Поддержка PDF-документов
- 🌍 Мультиязычность (RU/EN/DE/TJ)
- 🎨 Поддержка темной темы
- 📊 Аналитика чтения (новая)



### ⚙️ ТЕХНОЛОГИЧЕСКИЙ СТЕК

**Основные технологии:**
- **SwiftUI** + **MVVM** архитектура
- **iOS 17+** (минимальная версия)
- **@AppStorage** для хранения настроек
- **@ObservableObject** / **@EnvironmentObject** для управления состоянием
- **UserDefaults** для persistent data (через менеджеры)
- **Local JSON files** для данных статей

**Важные ограничения:**
- ❌ Избегать deprecated iOS 16 API
- ❌ Нет внешних зависимостей (кроме системных фреймворков)
- ❌ Нет сетевых запросов (полностью офлайн)
- ❌ Прямой доступ к UserDefaults запрещен (только через менеджеры)

**Поддерживаемые функции iOS:**
- Dark Mode поддержка
- ShareLink для расшаривания
- NavigationStack для навигации
- SwiftUI Animations
- Haptic Feedback



### 🏗️ АРХИТЕКТУРА ПРИЛОЖЕНИЯ

**Иерархия менеджеров и сервисов:**

// Singleton менеджеры (общие для всего приложения):
DataService.shared          // Загрузка JSON данных
CategoryManager.shared      // Управление категориями
RatingManager.shared        // Система рейтингов (1-5 звезд)
ReadingHistoryManager.shared // История чтения статей

// Менеджеры состояния (создаются в ContentView и передаются):
@StateObject var favoritesManager = FavoritesManager() // Управление избранным
@StateObject var locationManager = LocationManager()   // Геолокация (для карты)

// AppStorage настройки (децентрализованы):
@AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
@AppStorage("isDarkMode") var isDarkMode: Bool = false
// Хранение данных менеджеров также осуществляется через AppStorage внутри самих менеджеров


**Иерархия менеджеров и сервисов (дополнение из AI_CONTEXT2.md):**

// Singleton менеджеры (общие для всего приложения):
DataService.shared          // Загрузка данных
CategoryManager.shared      // Управление категориями
RatingManager.shared        // Управление рейтингами
ReadingHistoryManager.shared // История чтения
FavoritesManager()         // ❌ НЕ singleton - создается в ContentView

// Состояние через AppStorage:
@AppStorage("selectedLanguage") var selectedLanguage: String
@AppStorage("isDarkMode") var isDarkMode: Bool
@AppStorage("readingHistory") var storedHistory: Data
@AppStorage("favoriteArticles") var storedFavorites: Data = Data()
```

---

### 📊 МОДЕЛИ ДАННЫХ (Полная спецификация)

**Article Model:**
```swift
struct Article: Identifiable, Codable, Hashable {
    let id: String                    // UUID строки
    let title: [String: String]       // Локализованные заголовки ["ru": "...", "en": "..."]
    let content: [String: String]     // Локализованный контент
    let categoryId: String           // Связь с категорией
    let tags: [String]               // Массив тегов ["миграция", "работа"]
    let pdfFileName: String?         // Опционально: имя PDF файла
    let createdAt: Date?             // Дата создания (ISO8601)
    let updatedAt: Date?             // Дата обновления
    
    // Методы локализации (реализованы через стандартную fallback-цепочку):
    func localizedTitle(for language: String) -> String {
        title[language] ?? title["en"] ?? title.values.first ?? "No title"
    }
    func localizedContent(for language: String) -> String {
        content[language] ?? content["en"] ?? content.values.first ?? "No content"
    }
    func formattedReadingTime(for language: String) -> String
}
```

**Category Model:**

struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]  // Локализованные названия
    let icon: String           // SF Symbol name
    
    func localizedName(for language: String) -> String {
        name[language] ?? name["en"] ?? name.values.first ?? "No name"
    }
}


**Location Model:**
```swift
struct Location: Identifiable, Codable {
    let id: String
    let name: String          // Название на основном языке
    let latitude: Double     // Широта
    let longitude: Double    // Долгота
    var coordinate: CLLocationCoordinate2D { ... } // Computed property для MapKit
}
```

**ReadingHistoryEntry Model (из AI_CONTEXT2.md):**
```swift
struct ReadingHistoryEntry: Codable, Identifiable {
    let id: String
    let articleId: String
    let date: Date
    let readingTime: TimeInterval // ⚡ Важнейшее новое поле
}


### 🗂️ СТРУКТУРА ПРОЕКТА

```
InGermany/
├── 📁 Core/
│   ├── InGermanyApp.swift            // Точка входа, инициализация менеджеров
│   └── ContentView.swift             // Главный TabView с 5 вкладками
│
├── 📁 Views/
│   ├── HomeView.swift                // Домашний экран
│   ├── ArticleDetailView.swift       // Детальный просмотр статьи
│   ├── SearchView.swift              // Поиск с фильтрами
│   ├── FavoritesView.swift           // Избранное + поиск + фильтры
│   ├── CategoriesView.swift          // Список категорий
│   ├── ArticlesByCategoryView.swift  // Статьи по категории
│   ├── ArticlesByTagView.swift       // Статьи по тегу
│   ├── MapView.swift                 // Карта с локациями
│   ├── SettingsView.swift            // Настройки языка и темы
│   ├── AboutView.swift               // О приложении
│   │
│   └── 📁 Components/                // Переиспользуемые UI компоненты
│       ├── ArticleCardView.swift     // Карточка статьи для сеток
│       ├── ArticleRow.swift          // Строка статьи для списков
│       ├── FavoriteCard.swift        // Карточка для горизонтального скролла
│       ├── PDFViewer.swift           // Вьювер PDF документов
│       ├── ReadingProgressBar.swift  // Индикатор прогресса чтения
│       ├── TagFilterView.swift       // Компонент фильтрации по тегам
│       ├── RecentArticleCard.swift   // Карточка недавно прочитанного
│       └── ArticleRowWithReadingInfo.swift // Строка статьи с инфо о чтении
│
├── 📁 Models/
│   ├── Article.swift
│   ├── Category.swift
│   ├── Location.swift
│   ├── RatingManager.swift           // Менеджер рейтингов (singleton)
│   └── ReadingHistoryManager.swift   // Менеджер истории чтения (singleton)
│
├── 📁 Services/
│   ├── DataService.swift             // Загрузка данных из JSON
│   ├── AuthService.swift             // Сервис аутентификации (в разработке)
│   └── ShareService.swift            // Сервис расшаривания контента
│
├── 📁 Utils/
│   ├── CategoryManager.swift         // Доступ к категориям по ID (singleton)
│   ├── ReadingTimeCalculator.swift   // Калькулятор времени чтения
│   ├── ExportToPDF.swift             // Экспорт контента в PDF
│   ├── ProgressBar.swift             // Компонент прогресс-бара
│   ├── Animations.swift              // Кастомные анимации
│   └── Theme.swift                   // Тема и цвета приложения
│
├── 📁 Resources/
│   ├── articles.json                 // Данные статей (локализованные)
│   ├── categories.json               // Данные категорий
│   ├── locations.json                // Данные локаций для карты
│   ├── Test_Document.pdf             // Тестовый PDF документ
│   └── 📁 Screenshots/
│       ├── home.png
│       ├── article.png
│       ├── categories.png
│       ├── favorites.png
│       ├── search.png
│       └── settings.png
│
└── 📁 Supporting Files/
    ├── PROJECT_STRUCTURE.md
    ├── AI_CONTEXT.md                 // Этот файл
    └── Git_Mini_Guide.md

### 🛠️ СЕРВИСЫ И МЕНЕДЖЕРЫ (ДЕТАЛИ)

#### DataService (Singleton)

```swift
class DataService {
    static let shared = DataService()
    // Основные методы
    func loadArticles() -> [Article]
    func loadCategories() -> [Category]
    func loadLocations() -> [Location]
    
    // Вспомогательные методы
    func getArticles(for categoryId: String) -> [Article]
    func getArticles(with tag: String) -> [Article]
    func getArticle(by id: String) -> Article?
}
```

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
```

#### FavoritesManager (НЕ Singleton)

class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []
    
    // Основные методы
    func toggleFavorite(article: Article)
    func isFavorite(article: Article) -> Bool
    func favoriteArticles(from articles: [Article]) -> [Article]
    
    // Хранение в UserDefaults через JSON encoding
    private func saveFavorites()
    private func loadFavorites()
}
```

**Из AI_CONTEXT2.md (дополнение с новыми методами):**
```swift
class FavoritesManager: ObservableObject {
    @Published var favoriteIDs: Set<String>
    
    // Основные методы
    func toggleFavorite(article: Article)
    func isFavorite(article: Article) -> Bool
    func favoriteArticles(from articles: [Article]) -> [Article]
    
    // Новые методы
    func getFavoritesCount() -> Int
    func clearFavorites()
}
```

#### RatingManager (Singleton)
**Из AI_CONTEXT.md:**
```swift
class RatingManager {
    static let shared = RatingManager()
    private init() {}
    
    // Хранение: rating_<articleId> в UserDefaults
    func rating(for articleId: String) -> Int // 0-5
    func setRating(_ rating: Int, for articleId: String)
    
    // In-memory кэш для производительности
    @Published private var ratings: [String: Int] = [:]
}
```

**Из AI_CONTEXT2.md (дополнение с новыми методами):**
```swift
class RatingManager {
    static let shared = RatingManager()
    private init() {}
    
    func rating(for articleId: String) -> Int
    func setRating(_ rating: Int, for articleId: String)
    func getAverageRating() -> Double
    func getRatedArticlesCount() -> Int
}
```

#### ReadingHistoryManager (Singleton)
**Из AI_CONTEXT.md:**
```swift
class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()
    
    // Основные методы:
    func addReadingEntry(articleId: String, readingTime: TimeInterval)
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article]
    func isRead(_ articleId: String) -> Bool
    func lastReadDate(for articleId: String) -> Date?
    
    // Статистика:
    var totalReadingTimeMinutes: Int
    var totalArticlesRead: Int
    
    // ReadingTracker для реального времени (используется в ArticleView):
    func startReading(articleId: String)
    func finishReading()
    var currentReadingTime: TimeInterval
}
```

**Из AI_CONTEXT2.md (полное описание системы):**
```swift
class ReadingHistoryManager: ObservableObject {
    // Основные методы:
    func addReadingEntry(articleId: String, readingTime: TimeInterval)
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article]
    func isRead(_ articleId: String) -> Bool
    func lastReadDate(for articleId: String) -> Date?
    
    // Статистика:
    var totalReadingTimeMinutes: Int
    var totalArticlesRead: Int
    
    // ReadingTracker для реального времени:
    func startReading(articleId: String)
    func finishReading()
    var currentReadingTime: TimeInterval
}
```

**Из AI_CONTEXT2.md (дополнительные методы):**
```swift
class ReadingHistoryManager: ObservableObject {
    @Published var readArticles: Set<String>
    
    // Основные методы
    func markAsRead(articleId: String)
    func isArticleRead(articleId: String) -> Bool
    func getReadArticles() -> Set<String>
    
    // Статистика
    func getReadingStats() -> [String: Any]
    func getReadArticlesCount() -> Int
    func getReadingTimeEstimate() -> TimeInterval
}
```

#### ReadingTracker (Новый класс из AI_CONTEXT2.md)
```swift
class ReadingTracker: ObservableObject {
    func startReading(articleId: String)
    func finishReading()
    var currentReadingTime: TimeInterval
}
```

#### ReadingProgressTracker (Новый класс из AI_CONTEXT2.md)
```swift
// Используется в ArticleView:
Text(article.content)
    .trackReadingProgress(progressTracker)

ReadingProgressBar(progress: progressTracker.scrollProgress)
```

#### CategoryManager (Singleton)
**Из AI_CONTEXT.md:**
```swift
class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    func allCategories() -> [Category]
    func category(for id: String) -> Category?
}
```

**Из AI_CONTEXT2.md (дополнение):**
```swift
// Используется в HomeView:
private var allCategories: [Category] {
    CategoryManager.shared.allCategories()
}

// И в компонентах:
CategoryManager.shared.category(for: article.categoryId)
```

---

### 🌍 СИСТЕМА ЛОКАЛИЗАЦИИ (Важное уточнение)

**Из AI_CONTEXT.md:**
**❌ Centralized LocalizationManager ОТСУТСТВУЕТ.** Используется **децентрализованный подход**:

Каждый View содержит свою собственную функцию `getTranslation`:

```swift
// Пример реализации внутри View:
private func getTranslation(key: String, language: String) -> String {
    let translations: [String: [String: String]] = [
        "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
        "Карта локаций": ["ru": "Карта локаций", "en": "Location Map", "de": "Standortkarte", "tj": "Харитаи ҷойҳо"],
        "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
        // ... и так для каждого текстового ключа в этом View
    ]
    // Стандартная fallback-цепочка: запрошенный язык -> English -> первый доступный -> исходный ключ
    return translations[key]?[language] ?? translations[key]?["en"] ?? translations[key]?.values.first ?? key
}
```

**Поддерживаемые языки:** `ru`, `en`, `de`, `tj`

**Из AI_CONTEXT2.md (дополнение о децентрализованном подходе):**
```swift
// ❌ LocalizationManager.swift ПУСТОЙ - используется децентрализованный подход:

// Текущая реализация в каждом View:
private func getTranslation(key: String, language: String) -> String {
    let translations: [String: [String: String]] = [
        "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
        "Карта локаций": ["ru": "Карта локаций", "en": "Location Map", "de": "Standortkarte", "tj": "Харитаи ҷойҳо"],
        // ... и так для каждого ключа
    ]
    return translations[key]?[language] ?? key
}
```

**Из AI_CONTEXT2.md (дополнение о fallback-цепочке):**
```swift
// Для категорий:
name[language] ?? name["en"] ?? name.values.first ?? "No name"

// Для статей:
title[language] ?? title["en"] ?? title.values.first ?? "No title"
```

**Из AI_CONTEXT2.md (рекомендации для AI по локализации):**
```swift
// 1. Добавлять функцию getTranslation в каждом View
// 2. Использовать стандартную fallback цепочку
// 3. Добавлять все переводы для 4 языков

private func getTranslation(key: String, language: String) -> String {
    let translations: [String: [String: String]] = [
        "Новый ключ": [
            "ru": "Русский перевод",
            "en": "English translation",
            "de": "Deutsche Übersetzung",
            "tj": "Тарҷумаи тоҷикӣ"
        ]
    ]
    return translations[key]?[language] ?? key
}
```

**Из AI_CONTEXT2.md (работа с категориями):**
```swift
// Всегда использовать CategoryManager для доступа
let category = CategoryManager.shared.category(for: article.categoryId)
let categoryName = category?.localizedName(for: selectedLanguage) ?? "Без категории"

### 🎯 ТОЧНЫЕ ПАРАМЕТРЫ ДЛЯ КАЖДОГО ЭКРАНА (Критически важно)

**Из AI_CONTEXT.md:**
**Все View ДОЛЖНЫ получать следующие зависимости:**
```swift
@ObservedObject var favoritesManager: FavoritesManager // Создается в ContentView
let articles: [Article] // Все статьи приложения, загруженные через DataService
@AppStorage("selectedLanguage") private var selectedLanguage: String = "ru" // Децентрализовано
```

**Конкретные сигнатуры View:**

**HomeView:**
```swift
HomeView(
    favoritesManager: FavoritesManager,
    articles: [Article]
) // Внутри использует ReadingHistoryManager.shared и CategoryManager.shared
```

**ArticleDetailView:**
```swift
ArticleDetailView(
    article: Article,               // Текущая статья
    allArticles: [Article],         // Все статьи для рекомендаций
    favoritesManager: FavoritesManager
) // Внутри использует ReadingTracker и RatingManager.shared
```

**CategoriesView:**
```swift
CategoriesView(
    categories: [Category],      // Все категории
    articles: [Article],         // Все статьи
    favoritesManager: FavoritesManager
)
```

**SearchView:**
```swift
SearchView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

**FavoritesView:**
```swift
FavoritesView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

**SettingsView:**
```swift
SettingsView()  // Без параметров - управляет настройками через @AppStorage
```

**Из AI_CONTEXT2.md (дополнение и уточнение параметров):**
**Обязательные зависимости для View:**
```swift
// ВСЕ View должны получать эти зависимости:
@ObservedObject var favoritesManager: FavoritesManager
let articles: [Article]  // Все статьи приложения
let categories: [Category]? // Опционально, для некоторых View

// Настройки через AppStorage:
@AppStorage("isDarkMode") private var isDarkMode: Bool
@AppStorage("selectedLanguage") private var selectedLanguage: String
```

**ТОЧНЫЕ ПАРАМЕТРЫ ДЛЯ КАЖДОГО ЭКРАНА:**

**HomeView:**
```swift
HomeView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

**CategoriesView:**
```swift
CategoriesView(
    categories: [Category],      // Все категории
    articles: [Article],         // Все статьи
    favoritesManager: FavoritesManager
)
```

**SearchView:**
```swift
SearchView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

**FavoritesView:**
```swift
FavoritesView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

**SettingsView:**
```swift
SettingsView()  // Без параметров - управляет настройками через AppStorage
```

**Из AI_CONTEXT2.md (навигационные параметры):**
```swift
// Для ArticleDetailView
ArticleDetailView(
    article: Article,
    allArticles: [Article],
    favoritesManager: FavoritesManager
)

// Для фильтрованных списков
ArticlesByCategoryView(
    category: Category,
    articles: [Article],
    favoritesManager: FavoritesManager
)

ArticlesByTagView(
    tag: String,
    articles: [Article],
    favoritesManager: FavoritesManager
)
```

---

### 🏗️ АРХИТЕКТУРА HOMEVIEW (реальные данные)

**Из AI_CONTEXT2.md:**
**Обязательные зависимости HomeView:**
```swift
struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
    let articles: [Article]
    
    // ✅ Новые менеджеры для AI:
    @ObservedObject var readingHistoryManager  // Трекинг чтения
    private let allCategories = CategoryManager.shared.allCategories()
}

**Обязательные зависимости HomeView:**
```swift
struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
    let articles: [Article]
    
    // ✅ Новые менеджеры для AI:
    @ObservedObject var readingHistoryManager  // Трекинг чтения
    private let allCategories = CategoryManager.shared.allCategories()
}
```

**📊 СЕКЦИИ HOMEVIEW (точная структура)**

**1. Useful Tools Section:**
```swift
// Карта и случайная статья
NavigationLink { MapView() }
Button(action: { /* random article logic */ })
```

**2. Recently Read Section:**
```swift
let recentArticles = readingHistoryManager.recentlyReadArticles(from: articles, limit: 5)
// Использует RecentArticleCard компонент
```

**3. Favorites Section:**
```swift
let favorites = favoritesManager.favoriteArticles(from: articles)
// Использует FavoriteCard компонент
```

**4. Category Sections:**
```swift
// Динамически по всем категориям
ForEach(allCategories) { category in
    if let categoryArticles = articlesByCategory[category.id] {
        categorySection(category: category, articles: categoryArticles)
    }
}
```

**5. All Articles Section:**
```swift
// Полный список статей с ArticleRowWithReadingInfo
```

---

### 🎯 НОВЫЕ КОМПОНЕНТЫ (реальные из кода)


**RecentArticleCard:**
```swift
struct RecentArticleCard: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let lastReadDate: Date?  // ✅ Новое поле из ReadingHistoryManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}
```

**ArticleRowWithReadingInfo:**
```swift
struct ArticleRowWithReadingInfo: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let isRead: Bool  // ✅ От ReadingHistoryManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}
```

**CategoryArticleCard:**
```swift
struct CategoryArticleCard: View {
    let article: Article
    let category: Category  // ✅ Категория передается явно
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
}


### ⚡ КРИТИЧЕСКИ ВАЖНЫЕ СВЯЗИ

**Из AI_CONTEXT2.md:**

**Навигация к ArticleView:**
```swift
NavigationLink(
    destination: ArticleView(
        article: article,
        allArticles: articles,           // ✅ Все статьи для рекомендаций
        favoritesManager: favoritesManager
    )
) {
    // Компонент карточки
}
```

**Работа с ReadingHistoryManager:**
```swift
// Проверка прочитана ли статья
readingHistoryManager.isRead(article.id)

// Получение даты последнего чтения
readingHistoryManager.lastReadDate(for: article.id)

// Недавно прочитанные статьи
readingHistoryManager.recentlyReadArticles(from: articles, limit: 5)


### 🎨 СТИЛИ И АНИМАЦИИ (реальные из кода)


**Card Style:**
```swift
.cardStyle()  // Кастомный модификатор
.shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
.cornerRadius(12)
```

**Button Styles:**

.buttonStyle(AppleCardButtonStyle())  // Кастомный стиль кнопок


### 🌍 ЛОКАЛИЗАЦИЯ (реальные ключи)


**Используемые переводы:**

getTranslation(key: "Главная", language: selectedLanguage)
getTranslation(key: "Карта локаций", language: selectedLanguage)
getTranslation(key: "Случайная статья", language: selectedLanguage)
getTranslation(key: "Полезное", language: selectedLanguage)
getTranslation(key: "Недавно прочитанное", language: selectedLanguage)
getTranslation(key: "Избранное", language: selectedLanguage)
getTranslation(key: "Все статьи", language: selectedLanguage)
getTranslation(key: "Все", language: selectedLanguage)



### 📖 СИСТЕМА ИСТОРИИ ЧТЕНИЯ (ReadingHistoryManager) - Полное описание

class ReadingHistoryManager: ObservableObject {
    // Основные методы:
    func addReadingEntry(articleId: String, readingTime: TimeInterval)
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article]
    func isRead(_ articleId: String) -> Bool
    func lastReadDate(for articleId: String) -> Date?
    
    // Статистика:
    var totalReadingTimeMinutes: Int
    var totalArticlesRead: Int
    
    // ReadingTracker для реального времени:
    func startReading(articleId: String)
    func finishReading()
    var currentReadingTime: TimeInterval
}


**Из AI_CONTEXT2.md (дополнительные методы):**
```swift
class ReadingHistoryManager: ObservableObject {
    @Published var readArticles: Set<String>
    
    // Основные методы
    func markAsRead(articleId: String)
    func isArticleRead(articleId: String) -> Bool
    func getReadArticles() -> Set<String>
    
    // Статистика
    func getReadingStats() -> [String: Any]
    func getReadArticlesCount() -> Int
    func getReadingTimeEstimate() -> TimeInterval
}


### 🎯 ARTICLEVIEW ARCHITECTURE (детальная)


**Обязательные параметры:**
```swift
struct ArticleView: View {
    let article: Article          // Текущая статья
    let allArticles: [Article]    // Все статьи для рекомендаций
    @ObservedObject var favoritesManager: FavoritesManager
    
    // Менеджеры:
    @ObservedObject var ratingManager = RatingManager.shared
    @StateObject private var readingTracker = ReadingTracker()
    @StateObject private var progressTracker = ReadingProgressTracker()
}
```

**Ключевые функции:**
```swift
// 1. Отслеживание чтения
.onAppear { readingTracker.startReading(articleId: article.id) }
.onDisappear { readingTracker.finishReading() }

// 2. Прогресс скролла
Text(article.content).trackReadingProgress(progressTracker)

// 3. Навигация к началу
proxy.scrollTo("articleTop", anchor: .top)

// 4. Похожие статьи
private var relatedArticles: [Article] {
    allArticles
        .filter { $0.categoryId == article.categoryId && $0.id != article.id }
        .prefix(3)
        .map { $0 }
}
```

---

### ⚡ ВАЖНЫЕ ТЕХНИЧЕСКИЕ ДЕТАЛИ


**1. Haptic Feedback:**
```swift
HapticFeedback.medium()  // При добавлении в избранное
HapticFeedback.light()   // При прокрутке к началу
```

**2. ScrollViewReader:**
```swift
ScrollViewReader { proxy in
    ScrollView {
        // Контент с .id("articleTop")
    }
    .toolbar {
        Button { proxy.scrollTo("articleTop") }
    }
}
```

**3. ShareLink:**
```swift
ShareLink(
    item: "\(title)\n\n\(content)",
    subject: Text(title),
    message: Text("Поделитесь этой статьёй")
)

### 🎨 UI КОМПОНЕНТЫ (реальные из кода)

**Progress Bar:**
```swift
ReadingProgressBar(
    progress: progressTracker.scrollProgress,
    height: 6,
    foregroundColor: progressTracker.isReading ? .green : .blue
)
```

**Article Tools:**
```swift
// В Toolbar:
ToolbarItem(placement: .navigationBarTrailing) {
    Button { /* toggle favorite */ }
    Button { /* scroll to top */ }
}
```

---

### 🔍 СИСТЕМА ПОИСКА И ФИЛЬТРАЦИИ


**SearchView логика:**
```swift
// Многоуровневая фильтрация:
private var filteredArticles: [Article] {
    var results = articles
    
    // 1. Фильтрация по тегу
    if let tag = selectedTag {
        results = results.filter { $0.tags.contains(tag) }
    }
    
    // 2. Текстовый поиск
    if !searchText.isEmpty {
        results = results.filter { article in
            article.localizedTitle(for: selectedLanguage).contains(searchText) ||
            article.localizedContent(for: selectedLanguage).contains(searchText) ||
            CategoryManager.shared.category(for: article.categoryId)?.localizedName(for: selectedLanguage).contains(searchText) ?? false
        }
    }
    
    return results
}

**FavoritesView фильтрация:**
```swift
// Фильтрация избранного по категориям и поиску
private var filteredFavoriteArticles: [Article] {
    let favorites = favoritesManager.favoriteArticles(from: articles)
    
    // По категории
    if let selectedCategory = selectedCategory {
        filtered = filtered.filter { $0.categoryId == selectedCategory }
    }
    
    // По тексту
    if !searchText.isEmpty {
        filtered = filtered.filter { $0.title[selectedLanguage]?.contains(searchText) ?? false }
    }
}

### 🗺️ СИСТЕМА КАРТЫ (MapView)


**Архитектура карты:**
```swift
struct MapView: View {
    @StateObject private var locationManager = LocationManager() // Геолокация
    let locations: [Location] = DataService.shared.loadLocations()
    
    // Поддержка iOS 17+ и legacy
    @available(iOS 17.0, *) { Map(initialPosition: .region(region)) }
    else { Map(coordinateRegion: $region, annotationItems: locations) }
    
    // Кнопка "Мое местоположение"
    Button { region.center = locationManager.userLocation }
}
```

---

### 🎨 ДИЗАЙН СИСТЕМА (Theme.swift)


**Цвета и стили:**
```swift
struct Theme {
    // Цвета:
    static let primaryBlue = Color.blue
    static let secondaryGray = Color.secondary
    static let backgroundCard = Color(.systemBackground)
    
    // Градиенты:
    static let cardGradient = LinearGradient(...)
    static let favoriteCardGradient = LinearGradient(...)
    
    // Отступы:
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    
    // Тени:
    static let cardShadow = Shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
}

**Цветовая палитра (Theme.swift):**
```swift
enum AppColors {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let background = Color("Background")
    static let card = Color("Card")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}
```

**Типографика:**
- Title: `.title2/.title3`
- Body: `.body`
- Caption: `.caption`
- Использовать системные шрифты


### 📝 JSON СТРУКТУРА ДАННЫХ

**Пример статьи:**
```json
{
  "id": "3248bf6a-1e10-4e6d-8c73-d07ba9bce00f",
  "title": {
    "en": "Life Article #2",
    "ru": "Статья о жизни #2",
    "de": "Leben Artikel #2",
    "tj": "Мақола дар бораи ҳаёт #2"
  },
  "content": {
    "en": "Lorem ipsum...",
    "ru": "Лорем ипсум...",
    "de": "Lorem ipsum...",
    "tj": "Лорем ипсум..."
  },
  "categoryId": "55555555-5555-5555-5555-eeeeeeeeeeee",
  "tags": ["life", "жилье"],
  "pdfFileName": null,
  "createdAt": "2025-09-18T18:22:40Z",
  "updatedAt": "2025-09-18T18:22:40Z"
}
```

---

### 🔧 КРИТИЧЕСКИЕ НАСТРОЙКИ ДЛЯ AI


**При создании новых View:**
```swift
// 1. Всегда передавать allArticles для рекомендаций
// 2. Использовать ReadingTracker для отслеживания чтения
// 3. Добавлять HapticFeedback для действий
// 4. Использовать ScrollViewReader для навигации

// Правильный пример:
struct NewArticleView: View {
    let article: Article
    let allArticles: [Article]  // ✅ Обязательно!
    @ObservedObject var favoritesManager: FavoritesManager
    @StateObject private var readingTracker = ReadingTracker()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // Контент с .id("top")
            }
        }
        .onAppear { readingTracker.startReading(articleId: article.id) }
        .onDisappear { readingTracker.finishReading() }
    }
}
```

---

### 🚨 ИЗВЕСТНЫЕ ОГРАНИЧЕНИЯ

**1. FavoritesManager не singleton** - создается в ContentView и передается
**2. Локализация децентрализована** - в каждом View своя функция getTranslation
**3. ReadingProgressTracker** - требует реализации .trackReadingProgress модификатора

**Из AI_CONTEXT2.md (дополнительные ограничения):**
**1. Нет централизованной локализации** - каждый View сам управляет переводами
**2. Ключи могут дублироваться** между разными View
**3. Fallback логика стандартизирована** - всегда en → первый → дефолтный текст

---

### 📝 ПОЛНЫЙ ШАБЛОН НОВОГО VIEW


```swift
struct NewView: View {
    // Обязательные параметры
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    
    // Менеджеры
    @ObservedObject var ratingManager = RatingManager.shared
    @StateObject private var readingTracker = ReadingTracker()
    
    // Настройки
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    // Контент с .id("top")
                }
            }
        }
        .onAppear { readingTracker.startReading(articleId: article.id) }
        .onDisappear { readingTracker.finishReading() }
        .toolbar {
            ToolbarItem {
                Button {
                    favoritesManager.toggleFavorite(article: article)
                    HapticFeedback.medium()
                } label: {
                    Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                }
            }
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        // Локализация как в других View
    }
}
```

**Из AI_CONTEXT.md (дополнение):**
**Шаблон нового View:**
```swift
struct NewView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        // Реализация
    }
}


### 🚀 ROADMAP И ПЛАНЫ РАЗВИТИЯ

**Из AI_CONTEXT.md:**

#### Short-term (v1.6.0 - ближайшие 2 недели):
- [ ] 📊 **Завершить Reading Analytics** - детальная статистика чтения
- [ ] 📄 **Реализовать экспорт PDF** - утилита ExportToPDF
- [ ] 🎭 **Добавить анимации** - улучшить UX анимациями
- [ ] ⚡ **Оптимизация производительности** - уменьшить перерисовки

#### Medium-term (v1.7.0 - 1 месяц):
- [ ] ☁️ **Интеграция с Supabase** - замена локальных JSON
- [️ ] 🔔 **Push-уведомления** - уведомления о новых статьях
- [ ] 📱 **Виджеты для главного экрана** - быстрый доступ
- [ ] 🖼️ **Кэширование изображений** - подготовка к медиа

#### Long-term (v2.0.0 - 2-3 месяца):
- [ ] 🔐 **Авторизация пользователей** - система аккаунтов
- [ ] ☁️ **Синхронизация между устройствами** - cloud sync
- [ ] 💬 **Сообщество/комментарии** - интерактивные функции
- [ ] 🤖 **AI-рекомендации статей** - умные предложения

#### 🗑️ Deprecation计划:
- **Устаревшие Components** - постепенный рефакторинг
- **Legacy JSON структуры** - миграция к новой схеме
- **Старые iOS 16 API** - полный переход на iOS 17+

**Из AI_CONTEXT2.md (дополнение):**
**Short-term (v1.6.0 - ближайшие 2 недели):**
- [ ] 📊 **Завершить Reading Analytics** - детальная статистика чтения
- [ ] 📄 **Реализовать экспорт PDF** - утилита ExportToPDF
- [ ] 🎭 **Добавить анимации** - улучшить UX анимациями
- [ ] ⚡ **Оптимизация производительности** - уменьшить перерисовки

**Medium-term (v1.7.0 - 1 месяц):**
- [ ] ☁️ **Интеграция с Supabase** - замена локальных JSON
- [️ ] 🔔 **Push-уведомления** - уведомления о новых статьях
- [ ] 📱 **Виджеты для главного экрана** - быстрый доступ
- [ ] 🖼️ **Кэширование изображений** - подготовка к медиа

**Long-term (v2.0.0 - 2-3 месяца):**
- [ ] 🔐 **Авторизация пользователей** - система аккаунтов
- [ ] ☁️ **Синхронизация между устройствами** - cloud sync
- [ ] 💬 **Сообщество/комментарии** - интерактивные функции
- [ ] 🤖 **AI-рекомендации статей** - умные предложения

---

### 🤖 ИНСТРУКЦИЯ ДЛЯ AI-АССИСТЕНТОВ


**Строгие правила взаимодействия:**
1.  **Всегда запрашивайте контекст** перед генерацией кода.
2.  **Генерируйте полные файлы**, а не фрагменты.
3.  **Код должен быть SwiftLint-совместимым** и соответствовать iOS 17+ API.
4.  **Учитывайте децентрализованную локализацию** в каждом View.

**Ключевые триггер-фразы:**
```bash
# Для новых фич:
"И помоги оформить профессиональный коммит с сообщением"

# Для исправлений багов:
"Подскажи как правильно закоммитить эти правки"

# Для рефакторинга:
"Подготовь инструкцию для git commit этой переработки"

# Для документации:
"Обнови AI_CONTEXT.md с этими изменениями"
```


**📋 Строгие правила взаимодействия:**

1. **Всегда запрашивайте контекст:**
   - "Покажи текущую версию файла X"
   - "Какая структура данных для Y?"
   - "Какие параметры принимает Z View?"

2. **Генерация кода:**
   - ✅ Полные файлы (не фрагменты)
   - ✅ Соответствие существующей архитектуре
   - ✅ Учет локализации (все тексты через [String: String])
   - ✅ iOS 17+ API only

3. **Стиль и качество:**
   - ✅ SwiftLint-совместимый код
   - ✅ Комментарии для сложной логики
   - ✅ Обработка ошибок и edge cases
   - ✅ Unit testable код

**🎯 Ключевые триггер-фразы:**
```bash
# Для новых фич:
"И помоги оформить профессиональный коммит с сообщением"

# Для исправлений багов:
"Подскажи как правильно закоммитить эти правки"

# Для рефакторинга:
"Подготовь инструкцию для git commit этой переработки"

# Для документации:
"Обнови AI_CONTEXT.md с этими изменениями"
```

**🔍 Что я могу предоставить по запросу:**
- Любой файл проекта (.swift, .json, .md)
- Вывод git команд (log, status, diff, show)
- Скриншоты из приложения и Xcode
- Структуру проекта и зависимости
- Текущие ошибки компиляции

**⚠️ Частые ошибки которых следует избегать:**
- ❌ Использование устаревших iOS 16 API
- ❌ Прямой доступ к UserDefaults (только через Managers)
- ❌ Тексты без локализации (только [String: String])
- ❌ Нарушение архитектуры MVVM
- ❌ Ignoring @ObservableObject patterns

### ⚡ ВАЖНЕЙШИЕ ПРАВИЛА ДЛЯ AI (Архитектурные мандаты)


1.  **Все View должны получать `favoritesManager` и `articles`** и объявлять `@AppStorage("selectedLanguage")`.
2.  **Данные загружаются только через `DataService.shared`**.
3.  **Настройки только через `@AppStorage`**.
4.  **Локализация - децентрализованная**. Каждый новый View должен содержать свою функцию `getTranslation`.
5.  **Прямой доступ к UserDefaults запрещен**. Все операции через соответствующие менеджеры.
6.  **Для навигации к `ArticleDetailView` всегда передавать `allArticles`** для системы рекомендаций.
7.  **Использовать HapticFeedback для пользовательских действий** (добавление в избранное, скролл к началу).
8.  **Использовать `ScrollViewReader`** для реализации кнопки "Scroll to Top" в детальных просмотрах.

**Из AI_CONTEXT2.md (дополнение):**

**1. Все View ДОЛЖНЫ получать `favoritesManager` и `articles`**
**2. Данные загружаются через `DataService.shared`**
**3. Настройки через `@AppStorage`**
**4. Цветовая схема управляется через `.preferredColorScheme`**

**Правила работы с данными:**
```swift
// 1. Все данные локальные (JSON файлы)
// 2. Нет сетевых запросов (offline-only)
// 3. Кэширование в памяти при необходимости
// 4. Все изменения через менеджеры

// Правильный подход:
favoritesManager.toggleFavorite(article: article)

// Неправильный подход:
UserDefaults.standard.set(...) // напрямую
```

**Управление состоянием:**
```swift
// Использовать @State для локального состояния
@State private var searchText = ""

// Использовать @ObservedObject для обшего состояния
@ObservedObject var favoritesManager: FavoritesManager

// Использовать @EnvironmentObject для глобального состояния
@EnvironmentObject var localizationManager: LocalizationManager
```

**Все View должны использовать:**
```swift
struct MyView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var readingHistoryManager: ReadingHistoryManager
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @Environment(\.colorScheme) var colorScheme
    
    // Обязательный параметр для навигации
    let allArticles: [Article]
}


### 📞 КОНТАКТНАЯ ИНФОРМАЦИЯ


**Разработчик:** Umed Sabzaev
**Email:** umed@example.com
**GitHub:** https://github.com/UmedTJK
**Документация:** https://github.com/UmedTJK/InGermany/wiki

**Важные теги версий:**
- `v1.5.2-current` - текущая стабильная версия
- `v1.4.3-docs` - предыдущая документационная версия
- `v1.0.0` - первоначальная стабильная версия

**Из AI_CONTEXT2.md (дополнение):**
**Разработчик:** Umed Sabzaev
**Email:** umed@example.com
**GitHub:** https://github.com/UmedTJK
**Документация:** https://github.com/UmedTJK/InGermany/wiki

**Важные теги версий:**
- `v1.5.2-current` - текущая стабильная версия
- `v1.4.3-docs` - предыдущая документационная версия
- `v1.0.0` - первоначальная стабильная версия



### 📊 МЕНЕДЖЕРЫ И СОСТОЯНИЕ


**Обязательные зависимости для View:**
```swift
// ВСЕ View должны получать эти зависимости:
@ObservedObject var favoritesManager: FavoritesManager
let articles: [Article]  // Все статьи приложения
let categories: [Category]? // Опционально, для некоторых View

// Настройки через AppStorage:
@AppStorage("isDarkMode") private var isDarkMode: Bool
@AppStorage("selectedLanguage") private var selectedLanguage: String
```

---

### 🏗️ АРХИТЕКТУРА ПРИЛОЖЕНИЯ (завершение)

**Иерархия менеджеров:**
```swift
// Singleton менеджеры:
DataService.shared          // Загрузка данных
CategoryManager.shared      // Управление категориями
RatingManager.shared        // Управление рейтингами
ReadingHistoryManager.shared // История чтения
FavoritesManager()         // ❌ НЕ singleton - создается в ContentView

// Состояние через AppStorage:
@AppStorage("selectedLanguage") var selectedLanguage: String
@AppStorage("isDarkMode") var isDarkMode: Bool
@AppStorage("readingHistory") var storedHistory: Data


### 📝 ШАБЛОНЫ ДЛЯ НОВЫХ МОДЕЛЕЙ



**Базовая модель с локализацией:**
```swift
struct NewModel: Identifiable, Codable {
    let id: String
    let localizedTitle: [String: String]
    let localizedContent: [String: String]
    let icon: String?
    
    func title(for language: String) -> String {
        localizedTitle[language] ?? localizedTitle["en"] ?? localizedTitle.values.first ?? "No title"
    }
    
    func content(for language: String) -> String {
        localizedContent[language] ?? localizedContent["en"] ?? localizedContent.values.first ?? "No content"
    }
}

**Из AI_CONTEXT2.md (для создания LocalizationManager):**
```swift
// Прототип будущего менеджера
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private var translations: [String: [String: String]] = [:]
    
    func loadTranslations() {
        // Загрузка из JSON файла
    }
    
    func translate(_ key: String, for language: String) -> String {
        return translations[key]?[language] ?? key
    }
}

**Из AI_CONTEXT2.md (шаблон нового менеджера):**
```swift
class NewManager: ObservableObject {
    static let shared = NewManager()  // Singleton если общий
    
    @Published private var data: [String] = []
    @AppStorage("newData") private var storedData: Data = Data()
    
    private init() { loadData() }
    
    private func loadData() { /* из UserDefaults */ }
    private func saveData() { /* в UserDefaults */ }
}

### 🎯 КЛЮЧЕВЫЕ ОСОБЕННОСТИ ИЗ ВАШЕГО КОДА


**1. Децентрализованная локализация:**
- Каждый View содержит свой словарь переводов
- Нет единого LocalizationManager
- Ключи дублируются между View

**2. CategoryManager существует:**
```swift
// Используется в HomeView:
private var allCategories: [Category] {
    CategoryManager.shared.allCategories()
}

// И в компонентах:
CategoryManager.shared.category(for: article.categoryId)
```

**3. Стандартные fallback цепочки:**
```swift
// Для категорий:
name[language] ?? name["en"] ?? name.values.first ?? "No name"

// Для статей:
title[language] ?? title["en"] ?? title.values.first ?? "No title"


### 🔧 ДЛЯ СОЗДАНИЯ LocalizationManager (если решите добавить)


```swift
// Прототип будущего менеджера
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private var translations: [String: [String: String]] = [:]
    
    func loadTranslations() {
        // Загрузка из JSON файла
    }
    
    func translate(_ key: String, for language: String) -> String {
        return translations[key]?[language] ?? key
    }
}

**Документ актуален для:** `v1.5.2-current` (19.09.2025)
**Соответствует коммиту:** `ad3634e` (HEAD -> main)

*Этот файл является единым источником истины для всех AI-ассистентов и должен обновляться при любых значительных изменениях в проекте.*
