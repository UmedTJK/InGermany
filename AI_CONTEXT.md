# AI_CONTEXT2.md

## 📌 Описание
Документ для ИИ-агентов. Цель — моментальное понимание проекта **InGermany** и выдача релевантного кода и советов без потерь в контексте.

- Автор: Umed Sabzaev (Tajikistan → Germany, 2025)
- Контакт: GitHub https://github.com/UmedTJK/InGermany
- Стек: Swift, SwiftUI, iOS 17+, Xcode, Git

## 🔖 Версия документа
- Текущая версия: v1.5.2-current  
- Описание соответствует ветке **main** на коммит:  
  `1bd9c35 (20.09.2025) feat: загрузка данных из сети, кеш и обновление структуры проекта`  
- Последние изменения:
  - Добавлен `NetworkService` с кешированием
  - Динамический размер текста (TextSizeManager)
  - Swipe Actions и контекстное меню в избранном
  - Переработан HomeView с горизонтальными скроллами
  - FavoritesManager вынесен и задокументирован

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
│       ├── TagFilterView.swift       # Компонент фильтрации по тегам
│       └── TextSizeSettingsPanel.swift # Панель настроек текста (новая)
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
├── ├── NetworkService.swift          # Загрузка данных из сети, кеширование
│   └── ShareService.swift            # Сервис расшаривания контента

│
├── 📁 Utils/                         # Вспомогательные утилиты
│   ├── LocalizationManager.swift     # Управление локализацией
│   ├── CategoryManager.swift         # Доступ к категориям по ID
│   ├── ReadingTimeCalculator.swift   # Калькулятор времени чтения
│   ├── ExportToPDF.swift             # Экспорт контента в PDF
│   ├── ProgressBar.swift             # Компонент прогресс-бара
│   ├── Animations.swift              # Кастомные анимации
│   ├── Theme.swift                   # Тема и цвета приложения
│   └── TextSizeManager.swift         # Менеджер размера текста (новый)
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



### 📱 Тестирование
- Программа устанавливается и тестируется автором на личном iPhone.
- Это гарантирует работу на реальном устройстве, а не только в симуляторе.
- AI-агенты должны учитывать это и предлагать сценарии тестирования, подходящие для реального устройства (офлайн-режим, авиарежим, поведение при слабом интернете).


## 🧠 Важно для AI-агентов

1. **FavoritesManager**
   - Не singleton, создаётся в `ContentView`.
   - Должен передаваться вниз во все View через `.environmentObject`.
   - Не дублировать состояние избранного в локальных `@State`.

2. **Локализация**
   - Сейчас децентрализована: `@AppStorage("selectedLanguage")` + методы моделей (`localizedTitle`, `localizedContent`).
   - ⚠️ В будущем планируется вынести в `LocalizationManager`.
   - Новые View должны читать язык только через `@AppStorage`.

3. **Источники данных**
   - `DataService` → загрузка JSON локально или из сети.
   - `NetworkService` с кешем → fallback на локальные ресурсы.
   - `HomeView` показывает источник (network/cache/local).

4. **Модели**
   - Всегда использовать `Article`, `Category`, `Location`.
   - `ReadingHistoryManager` определяет прочитанность (>80% скролла).

5. **UI**
   - Строго использовать готовые компоненты:
     - ArticleCardView, ArticleRow, FavoriteCard, PDFViewer, ReadingProgressBar, TagFilterView, TextSizeSettingsPanel.
   - Категории тянутся из `CategoriesStore`.
   -⚠️ Временно локализация UI-строк децентрализована (реализована прямо во View и моделях). 
ИИ не должен предполагать централизованное решение, пока не внедрён LocalizationManager.

6. **Roadmap**
   - Все новые фичи должны согласовываться с планами (PDF export, цитаты, индикатор прогресса, история чтения).


7. **Соответствие Roadmap**
   - ИИ должен проверять, что предлагаемые улучшения согласуются с планами.
   - Например, не предлагать Firebase или облачное хранилище, пока они не вернутся в mid-term.

8. **Git и профессиональный рабочий процесс**
   - AI-агенты должны напоминать разработчику работать с Git по правилам из `COMMIT_GUIDE.md`.
   - Поддерживать профессиональный стиль: использование веток (feature/, fix/, docs/), теги релизов (v1.x.x), обновление CHANGELOG.md.
   - При старте работы над задачей AI-агенты могут предлагать:
     • Создать новую ветку.
     • Выбрать правильный тип коммита (feat, fix, docs, refactor, chore).
     • Создать тег при релизе и описать его в CHANGELOG.md.





## 📊 Модели данных

### **Article**
- Поля:
  - `id: UUID`
  - `title: [String: String]` (локализованные заголовки)
  - `content: [String: String]` (локализованный текст)
  - `tags: [String]`
  - `categoryId: String`
  - `createdAt: Date?`
  - `updatedAt: Date?`
- Методы:
  - `localizedTitle(for language: String) -> String`
  - `localizedContent(for language: String) -> String`

### **Category**
- Поля:
  - `id: UUID`
  - `name: [String: String]`
  - `icon: String` (systemImage)
- Методы:
  - `localizedName(for language: String) -> String`

### **Location**
- Поля:
  - `id: UUID`
  - `name: [String: String]`
  - `latitude: Double`
  - `longitude: Double`
- Методы:
  - `localizedName(for language: String) -> String`

### **RatingManager**
- Позволяет пользователю выставлять рейтинг статье.
- Хранение: `UserDefaults`.
- API:
  - `getRating(for articleId: String) -> Int`
  - `setRating(for articleId: String, rating: Int)`

### **ReadingHistoryManager**
- Определяет, какие статьи были прочитаны.
- Логика: статья считается прочитанной, если пользователь пролистал >80% текста.
- API:
  - `markAsRead(_ article: Article)`
  - `isRead(_ article: Article) -> Bool`
  - `recentArticles(limit: Int) -> [Article]`
- Используется в HomeView («Недавно прочитанное») и ArticleView (чекмарки).
- В HomeView выводит последние N статей, порядок — по дате чтения (последнее просмотренное сверху).


---

## 🛠 Сервисы и менеджеры (детали)

### **DataService**
- Отвечает за загрузку JSON из локальных ресурсов (`articles.json`, `categories.json`, `locations.json`).
- Имеет fallback: если нет сети — данные берутся из `Bundle.main`.
- Методы:
  - `loadArticles()`
  - `loadCategories()`
  - `loadLocations()`

### **NetworkService**
- Загружает JSON по ссылке с GitHub (raw.githubusercontent).
- Имеет кеширование на диск.
- API:
  - `fetchArticles() async throws -> [Article]`
  - `fetchCategories() async throws -> [Category]`
  - `fetchLocations() async throws -> [Location]`
- В связке с DataService даёт стратегию «Network → Cache → Local».
#### Дополнительно
- Источником сетевых данных является GitHub Pages (raw.githubusercontent).
- Используется для загрузки `articles.json`, `categories.json`, `locations.json`.
- Логика fallback: Network → Cache → Local bundle.

### **AuthService**
- Заготовка для будущей аутентификации (сейчас пустой/минимальный).

### **ShareService**
- Упрощает шэринг статей через `ShareLink`.

### **FavoritesManager**
- Расположение: `Views/FavoritesManager.swift`
- Хранение: `@AppStorage("favoriteArticles")` (JSON-массив ID).
- API:
  - `isFavorite(id:)`
  - `toggleFavorite(id:)`
  - `toggleFavorite(article:)`
  - `favoriteArticles(from:)`
- Используется во всех экранах с сердечком.
- Важно: создаётся в ContentView и передаётся вниз через `.environmentObject`.



## 🛠 Utils и вспомогательные сервисы

### **Animations**
- Набор кастомных анимаций и HapticFeedback.
- Используется в ArticleCardView, FavoriteCard.

### **CategoriesStore**
- ObservableObject, хранит список категорий.
- Используется для получения локализованных названий по ID.

### **CategoryManager**
- Утилита для поиска категории по ID.

### **ExportToPDF**
- Экспорт статьи в PDF (ReportLab → PDFKit).
- Вызывается из ArticleDetailView.

### **LocalizationManager**
- Заготовка для централизованной локализации.
- Сейчас не используется (локализация реализована в моделях и во View).
- ⚠️ Планируется миграция всех UI-строк сюда.

### **ProgressBar**
- Общий компонент прогресс-бара (используется в разных местах).

### **ReadingTimeCalculator**
- Считает примерное время чтения.
- Учитывает язык статьи (разная скорость для ru/en/de/tj).

### **TextSizeManager**
- ObservableObject.
- Управляет динамическим размером текста (12–30pt).
- Связан с `SettingsView` и `TextSizeSettingsPanel`.

### **Theme**
- Определяет цветовую схему и стили.
- Используется глобально во всех View.


## 📱 Views (экраны)

### **HomeView**
- Главный экран.
- Секции:
  1. Источник данных (network/cache/local).
  2. Инструменты (MapView, PDFViewer, Random Article).
  3. Недавно прочитанное.
  4. Избранное.
  5. Категории (до 5 статей).
  6. Все статьи.
- Pull-to-refresh, навигация к ArticleView/MapView.

#### ArticleRowWithReadingInfo
- Показывает статью с иконкой, категорией, временем чтения, избранным и статусом «прочитано».

---

### **MapView**
- Показывает точки из `locations.json`.
- iOS 17+: `Map(initialPosition:)`.
- iOS 16-: fallback `Map(coordinateRegion:)`.
- Toolbar:
  - Моё местоположение.
  - Обновить данные.
- Начальная точка: центр Тюрингии.

---

### **ArticleView**
- Полное чтение статьи.
- Включает: заголовок, категорию, текст, дату создания/обновления.
- Фичи:
  - Прогресс-бар чтения.
  - Время чтения.
  - Избранное.
  - Рейтинг.
  - Поделиться.
  - Похожие статьи по тегам.
  - Динамический размер текста.

---

### **ArticleDetailView**
- Краткая версия просмотра.
- Toolbar:
  - Избранное.
  - Экспорт в PDF.

---

### **FavoritesView**
- Список избранного.
- Фильтрация по категориям.
- Поиск по заголовку.
- Swipe-действия: удалить из избранного, поделиться.

---

### **SearchView**
- Поиск по статьям.
- Фильтр по тегам (`TagFilterView`).
- Поддержка `.searchable`.

---

### **SettingsView**
- Секции:
  1. Язык приложения.
  2. Внешний вид (тема, размер текста).
  3. Статистика чтения.
  4. О приложении.
- Поддержка сброса истории и кастомного размера текста.

---

### **AboutView**
- Информация о проекте, авторе, ссылка на GitHub.

---

### **CategoriesView**
- Список категорий с иконками.
- Навигация в ArticlesByCategoryView.

---

### **ArticlesByCategoryView / ArticlesByTagView**
- Фильтруют статьи по категории или тегу.
- Навигация в ArticleDetailView.

---

## 🧩 Components

### **ArticleCardView**
- Карточка статьи (заголовок, превью, теги, избранное).
- Контекстное меню: избранное, поделиться, инфо.

### **ArticleRow**
- Строка статьи для списков.
- SwipeActions: избранное, поделиться.

### **FavoriteCard**
- Карточка избранного (иконка категории, заголовок, капсула).
- Анимация bounce при добавлении.

### **Components.swift**
- Содержит:
  - ToolCard
  - RecentArticleCard
  - EmptyFavoritesView
  - CategoryFilterButton

### **PDFViewer**
- Отображение PDF через PDFKit.
- Ошибка, если файл не найден.

### **ReadingProgressBar**
- ReadingProgressBar (линейный).
- ReadingProgressTracker (ObservableObject).
- ScrollTrackingModifier.
- ReadingProgressView (с процентами).
- CircularReadingProgress (круговой стиль).

### **TagFilterView**
- Горизонтальный скролл тегов.
- Вызывает callback onTagSelected.

### **TextSizeSettingsPanel**
- Настройка размера текста (slider + пресеты).
- Кнопка сброса, предпросмотр.
- Полная мультиязычность.
- Haptic feedback.


## 🔖 Часть 5. Roadmap и зависимости


## 🚀 Roadmap

### Short-term (1–2 месяца)
- 📤 Экспорт статьи в PDF (ArticleView).
- 📅 Дата публикации и обновления в ArticleView.
- 🎛️ Выбор размера шрифта (TextSizeSettingsPanel везде).
- 💬 Поддержка цитат/врезок в статьях.
- 📈 История прочтения (видел/не видел, дата).
- ⏱ Оценка времени чтения (ReadingTimeCalculator).
- 📊 Индикатор прогресса чтения (ReadingProgressBar).

### Mid-term (3–6 месяцев)
- 🔍 Умный поиск (поиск по фразам, синонимам).
- 🗄️ Firebase/Supabase для хранения данных в облаке.
- 📱 Улучшение UI (более современный дизайн).
- 🧪 Unit-тесты для ViewModel и сервисов.

### Long-term (6–12 месяцев)
- 🌐 Онлайн-режим с синхронизацией статей.
- 👥 Пользовательские аккаунты.
- ⭐ Сохранение прогресса и статистики в облаке.
- 📲 Публикация в App Store как showcase-проекта.



## 🔌 Внешние библиотеки и изменения
- **PDFKit** — для рендеринга и просмотра PDF.
- **CoreLocation / MapKit** — для работы карты.
- **Firebase** — ранее интегрирован, удалён в v1.5.0 (commit `ad3634e`).
- Проект работает офлайн, загружает JSON с GitHub (NetworkService + кеш).



## 🔖 Версионность
- Текущий документ: `v1.5.2-current`
- Соответствует ветке **main**, коммит:  
  `1bd9c35 (20.09.2025) feat: загрузка данных из сети, кеш и обновление структуры проекта`
- Последние ключевые изменения:
  - Добавлен NetworkService с кешем.
  - Динамический размер текста.
  - SwipeActions и контекстное меню в избранном.
  - Переработан HomeView с горизонтальными скроллами.
  - FavoritesManager задокументирован и вынесен в отдельный блок.
