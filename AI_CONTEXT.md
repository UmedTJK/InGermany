AI_CONTEXT.md

## 📌 Описание
Документ для ИИ-агентов. Цель — моментальное понимание проекта **InGermany** и выдача релевантного кода и советов без потерь в контексте.

- Автор: Umed Sabzaev (Tajikistan → Germany, 2025)
- Контакт: GitHub https://github.com/UmedTJK/InGermany
- Стек: Swift, SwiftUI, iOS 17+, Xcode, Git

## 🔖 Версия документа
- Текущая версия: v1.5.3-actor-refactor  
- Описание соответствует ветке **main** на коммит:  
  `2cf87d1 (21.09.2025) refactor: migrate DataService & CategoryManager to actor`  
- Последние изменения:
  - `DataService` переписан на `actor`, методы async, добавлен `getLastDataSource()`.
  - `CategoryManager` переписан на `actor`, убран `.shared`, добавлен глобальный `categoryManager`.
  - В модель `Category` добавлено поле `colorHex`.
  - `HomeView` и `CategoriesView` теперь используют `colorHex` для окрашивания категорий.
  - Обновлён `ArticlesByCategoryView` для поддержки `colorHex`.

### 🗂️ СТРУКТУРА ПРОЕКТА (ДЕТАЛЬНАЯ)


InGermany/
├── 📁 Core/                          # Основные файлы приложения
│   ├── InGermanyApp.swift            # Точка входа, инициализация менеджеров
│   └── ContentView.swift             # Главный TabView с 5 вкладками
│
├── 📁 Views/                         # Все экраны приложения
│   ├── HomeView.swift                # Домашний экран (полностью переработан, поддержка colorHex)
│   ├── ArticleDetailView.swift       # Детальный просмотр статьи
│   ├── SearchView.swift              # Поиск с фильтрами
│   ├── FavoritesView.swift           # Избранное + поиск + фильтры
│   ├── CategoriesView.swift          # Список категорий (colorHex + иконки)
│   ├── ArticlesByCategoryView.swift  # Статьи по категории (colorHex)
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
│       ├── TagFilterView.swift       # Компонент фильтрации по тегам
│       └── TextSizeSettingsPanel.swift # Панель настроек текста (новая)
│
├── 📁 Models/                        # Модели данных
│   ├── Article.swift                 # Модель статьи
│   ├── Category.swift                # Модель категории (colorHex)
│   ├── Location.swift                # Модель локации
│   ├── RatingManager.swift           # Менеджер рейтингов (singleton)
│   └── ReadingHistoryManager.swift   # Менеджер истории чтения (новый)
│
├── 📁 Services/                      # Сервисы работы с данными
│   ├── DataService.swift             # Загрузка данных (actor, async/await, getLastDataSource)
│   ├── AuthService.swift             # Сервис аутентификации (в разработке)
│   ├── NetworkService.swift          # Загрузка данных из сети, кеширование
│   └── ShareService.swift            # Сервис расшаривания контента
│
├── 📁 Utils/                         # Вспомогательные утилиты
│   ├── LocalizationManager.swift     # Управление локализацией
│   ├── CategoryManager.swift         # Доступ к категориям (actor, глобальный categoryManager)
│   ├── ReadingTimeCalculator.swift   # Калькулятор времени чтения
│   ├── ExportToPDF.swift             # Экспорт контента в PDF
│   ├── ProgressBar.swift             # Компонент прогресс-бара
│   ├── Animations.swift              # Кастомные анимации
│   ├── Theme.swift                   # Тема и цвета приложения
│   └── TextSizeManager.swift         # Менеджер размера текста (новый)
│
├── 📁 Resources/                     # Ресурсы приложения
│   ├── articles.json                 # Данные статей (локализованные)
│   ├── categories.json               # Данные категорий (добавлен colorHex)
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



 
## 3. МОДЕЛИ

### 📰 Article.swift
- Основная модель статьи.
- Структура:
  ```swift
  struct Article: Identifiable, Codable {
      let id: String
      let title: [String: String]
      let content: [String: String]
      let categoryId: String
      let tags: [String]
      let readingTime: Int
      let publishedAt: Date?
      let updatedAt: Date?
  }
````

* Ключевые моменты:

  * `title` и `content` локализованы (словарь: язык → текст).
  * `readingTime` указывается в минутах, используется в `ReadingTimeCalculator`.
  * `tags` — массив строк для фильтрации.
  * `publishedAt` и `updatedAt` — даты публикации и последнего обновления (будут использованы в будущем релизе для отображения).
* Методы:

  * `localizedTitle(for:)` — заголовок для выбранного языка.
  * `localizedContent(for:)` — текст статьи для языка.
  * `formattedReadingTime(for:)` — строка вроде `"5 мин"` или `"5 min"`.
* Моки:

  ```swift
  extension Article {
      static let sampleArticle = Article(
          id: "sample-1",
          title: ["ru": "Пример статьи", "en": "Sample Article"],
          content: ["ru": "Текст статьи", "en": "Article text"],
          categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa",
          tags: ["пример", "тест"],
          readingTime: 4,
          publishedAt: nil,
          updatedAt: nil
      )
  }
  ```
* Применение:

  * В превью и тестах UI (`#Preview`) используются `sampleArticle` или массивы с ним.
  * В реальном приложении данные подгружаются через `DataService`.

---

### 📂 Category.swift

* Модель категории.
* **НОВОЕ:** добавлено поле `colorHex` (например, `"#FF5733"`).
* Структура:

  ```swift
  struct Category: Identifiable, Codable {
      let id: String
      let name: [String: String]
      let icon: String
      let colorHex: String

      func localizedName(for language: String) -> String {
          name[language] ?? name["en"] ?? "—"
      }
  }
  ```
* Использование:

  * `CategoriesView` — список категорий (иконка + цвет из `colorHex`).
  * `HomeView` → `categorySection` теперь окрашивает иконку через:

    ```swift
    Image(systemName: category.icon)
        .foregroundColor(Color(hex: category.colorHex) ?? .blue)
    ```
  * `ArticlesByCategoryView` → заголовок также может использовать цвет категории.
* Моки:

  ```swift
  extension Category {
      static let sampleCategories: [Category] = [
          Category(
              id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
              name: ["ru": "Финансы", "en": "Finance"],
              icon: "banknote",
              colorHex: "#4A90E2"
          ),
          Category(
              id: "22222222-2222-2222-2222-bbbbbbbbbbbb",
              name: ["ru": "Работа", "en": "Work"],
              icon: "briefcase",
              colorHex: "#27AE60"
          )
      ]
  }
  ```
* Источник данных:

  * `categories.json` теперь расширен и для каждой категории есть ключ `colorHex`.

---

### 📍 Location.swift

* Модель для карты.
* Структура:

  ```swift
  struct Location: Identifiable, Codable {
      let id: String
      let title: [String: String]
      let latitude: Double
      let longitude: Double
  }
  ```
* Применение:

  * Используется в `MapView` для отображения точек.
  * Загружается из `locations.json` через `DataService`.


## 4. СЕРВИСЫ

### 📡 DataService.swift
- **НОВОЕ:** теперь реализован как `actor` (раньше был `@MainActor class`).  
- Задачи:
  - Загрузка статей, категорий и локаций.
  - Кеширование данных в памяти.
  - Падение в локальные JSON из `Bundle`, если нет сети.
  - Хранение источника данных (`network`, `memory_cache`, `local`) для UI.

- Структура:
  ```swift
  actor DataService {
      static let shared = DataService()

      private let networkService = NetworkService.shared
      private var articlesCache: [Article]?
      private var categoriesCache: [Category]?
      private var locationsCache: [Location]?
      private var lastDataSource: [String: String] = [:]

      private init() {}

      // MARK: - Асинхронная загрузка
      func loadArticles() async -> [Article] { ... }
      func loadCategories() async -> [Category] { ... }
      func loadLocations() async -> [Location] { ... }

      // MARK: - Кеш
      func clearCache() { ... }
      func refreshData() async { ... }

      // MARK: - Новый API
      func getLastDataSource() async -> [String: String] {
          return lastDataSource
      }
  }
````

* Применение:

  ```swift
  let articles = await DataService.shared.loadArticles()
  let sources = await DataService.shared.getLastDataSource()
  let dataSource = sources["articles"] ?? "unknown"
  ```

* Источник данных влияет на UI:

  * `network` → зелёная полоса.
  * `memory_cache` → синяя полоса.
  * `local` → оранжевая полоса.
  * `unknown` → серая полоса.

---

### 📂 CategoryManager.swift

* **НОВОЕ:** переписан как `actor`.

* Предназначение: централизованная работа с категориями.

* Раньше был `CategoryManager.shared`, теперь это убрано.

* Структура:

  ```swift
  actor CategoryManager {
      private let dataService = DataService.shared
      private var categories: [Category] = []

      init() {}

      func loadCategories() async {
          categories = await dataService.loadCategories()
      }

      func allCategories() -> [Category] {
          categories
      }

      func category(for id: String) -> Category? {
          categories.first { $0.id == id }
      }

      func category(for name: String, language: String = "en") -> Category? {
          categories.first { $0.localizedName(for: language) == name }
      }

      func refreshCategories() async {
          await dataService.clearCache()
          await loadCategories()
      }
  }

  // Глобальный экземпляр
  let categoryManager = CategoryManager()
  ```

* Использование:

  ```swift
  await categoryManager.loadCategories()
  let list = await categoryManager.allCategories()
  if let finance = await categoryManager.category(for: "11111111-1111-1111-1111-aaaaaaaaaaaa") {
      print(finance.localizedName(for: "ru"))
  }
  ```

---

### 🌐 NetworkService.swift

* Отвечает за загрузку JSON с GitHub Pages.
* Работает через `async/await`.
* Есть кэш на уровне URLSession.
* Метод:

  ```swift
  func loadJSON<T: Decodable>(from urlString: String) async throws -> T
  ```
* Пример:

  ```swift
  let articles: [Article] = try await networkService.loadJSON(from: "articles.json")
  ```

---

### 📤 ShareService.swift

* Предоставляет функционал шаринга статей или PDF.
* Реализован как утилита.
* В будущем — интеграция с системным `UIActivityViewController`.

---

### 🔑 AuthService.swift (в разработке)

* Планируется: регистрация пользователя, хранение токенов, вход через Apple ID/Google.
* Сейчас — заглушка.




# 📝 Обновлённый AI\_CONTEXT.md (часть 4 — Utils)

````markdown
## 5. УТИЛИТЫ (Utils)

### 🌍 LocalizationManager.swift
- Управление текущим языком приложения.
- Работает через `@AppStorage("selectedLanguage")`.
- Поддерживаемые языки: **ru, en, de, tj**.
- Пример:
  ```swift
  @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
  Text(article.localizedTitle(for: selectedLanguage))
````

---

### ⭐ FavoritesManager.swift

* Менеджер для работы с избранными статьями.
* Реализован как `ObservableObject`.
* Хранение через `UserDefaults` или `AppStorage`.
* Методы:

  * `add(_ article: Article)`
  * `remove(_ article: Article)`
  * `isFavorite(_ article: Article) -> Bool`
* Используется в:

  * `HomeView` → секция избранного.
  * `ArticleView` → кнопка "Добавить в избранное".

---

### 📖 ReadingHistoryManager.swift

* Менеджер истории чтения статей.
* Singleton (через `shared`).
* Хранит:

  * `isRead(articleId:)`
  * `markAsRead(articleId:)`
  * `lastReadDate(articleId:)`
* Используется в:

  * `ArticleRowWithReadingInfo` → зелёная галочка.
  * `HomeView` → секция «Недавно прочитанное».

---

### ⏱️ ReadingTimeCalculator.swift

* Утилита для расчёта времени чтения статьи.
* Принимает количество слов + язык (для скорости чтения).
* Возвращает минуты.
* Пример:

  ```swift
  let minutes = ReadingTimeCalculator.calculate(for: article, language: "ru")
  ```

---

### 🎨 Theme.swift

* Управление цветами и стилями приложения.
* Поддержка светлой и тёмной темы.
* Вынесенные константы:

  * `primaryColor`
  * `secondaryColor`
  * `backgroundColor`
* Используется во всех вью.

---

### ✨ Animations.swift

* Содержит кастомные анимации.
* Пример: анимация появления карточек на главной странице.
* Используется в `HomeView`, `ArticleCardView`.

---

### 📊 ProgressBar.swift

* Компонент прогресс-бара (SwiftUI View).
* Используется как индикатор чтения статьи.
* Пример:

  ```swift
  ProgressBar(value: progress)
      .frame(height: 4)
  ```

---

### 🗂️ ExportToPDF.swift

* Экспорт статьи в PDF.
* Использует `PDFKit`.
* Поддержка кириллицы и латиницы.
* В будущем — экспорт с форматированием (заголовки, цитаты).

---

### 🔠 TextSizeManager.swift

* **НОВОЕ (в разработке):**
* Менеджер изменения размера шрифта в приложении.
* Хранит текущее значение через `@AppStorage("fontSize")`.
* Используется в `SettingsView`.

---

### 📂 CategoryManager.swift

* ⚠️ ВАЖНО: переписан как `actor`.
* Раньше был `CategoryManager.shared`, теперь доступ через глобальный экземпляр:

  ```swift
  let categoryManager = CategoryManager()
  ```
* Методы:

  * `loadCategories() async`
  * `allCategories() -> [Category]`
  * `category(for id: String)`
  * `category(for name: String, language:)`
  * `refreshCategories() async`
* Используется в `CategoriesStore` и `HomeView`.
* Все вызовы выполняются через `await`.

