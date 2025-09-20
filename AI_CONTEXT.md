## 🧠 AI_CONTEXT.md (Версия 2.0 - Объединенная и Актуализированная)

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

---

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

---

### 🏗️ АРХИТЕКТУРА ПРИЛОЖЕНИЯ

**Иерархия менеджеров и сервисов:**
```swift
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
}
```

**Category Model:**
```swift
struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]  // Локализованные названия
    let icon: String           // SF Symbol name
    
    func localizedName(for language: String) -> String {
        name[language] ?? name["en"] ?? name.values.first ?? "No name"
    }
}
```

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

---

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
│
└── 📁 Supporting Files/
    ├── PROJECT_STRUCTURE.md
    ├── AI_CONTEXT.md                 // Этот файл
    └── Git_Mini_Guide.md
```

---

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

#### FavoritesManager (НЕ Singleton)
```swift
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

#### RatingManager (Singleton)
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

#### ReadingHistoryManager (Singleton)
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

#### CategoryManager (Singleton)
```swift
class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    func allCategories() -> [Category]
    func category(for id: String) -> Category?
}
```

---

### 🌍 СИСТЕМА ЛОКАЛИЗАЦИИ (Важное уточнение)

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

---

### 🎯 ТОЧНЫЕ ПАРАМЕТРЫ ДЛЯ КАЖДОГО ЭКРАНА (Критически важно)

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

---

### ⚡ ВАЖНЕЙШИЕ ПРАВИЛА ДЛЯ AI (Архитектурные мандаты)

1.  **Все View должны получать `favoritesManager` и `articles`** и объявлять `@AppStorage("selectedLanguage")`.
2.  **Данные загружаются только через `DataService.shared`**.
3.  **Настройки только через `@AppStorage`**.
4.  **Локализация - децентрализованная**. Каждый новый View должен содержать свою функцию `getTranslation`.
5.  **Прямой доступ к UserDefaults запрещен**. Все операции через соответствующие менеджеры.
6.  **Для навигации к `ArticleDetailView` всегда передавать `allArticles`** для системы рекомендаций.
7.  **Использовать HapticFeedback для пользовательских действий** (добавление в избранное, скролл к началу).
8.  **Использовать `ScrollViewReader`** для реализации кнопки "Scroll to Top" в детальных просмотрах.

---

### 🚀 ROADMAP И ПЛАНЫ РАЗВИТИЯ

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

---

### 📞 КОНТАКТНАЯ ИНФОРМАЦИЯ

**Разработчик:** Umed Sabzaev  
**Email:** umed@example.com  
**GitHub:** https://github.com/UmedTJK  
**Документация:** https://github.com/UmedTJK/InGermany/wiki  

**Важные теги версий:**
- `v1.5.2-current` - текущая стабильная версия
- `v1.4.3-docs` - предыдущая документационная версия
- `v1.0.0` - первоначальная стабильная версия

---

**Документ актуален для:** `v1.5.2-current` (19.09.2025)  
**Соответствует коммиту:** `ad3634e` (HEAD -> main)  
**Статус:** Объединенная и актуализированная версия (v2.0)

*Этот файл является единым источником истины для всех AI-ассистентов и должен обновляться при любых значительных изменениях в проекте.*
