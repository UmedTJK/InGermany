## 🧠 AI\_CONTEXT.md (v1.4.2-related)

Актуальный технический и логический контекст проекта **InGermany** для взаимодействия с AI. Обеспечивает понимание архитектуры, структуры данных, ответственности модулей и взаимодействия компонентов.

---

### 📌 Общая цель проекта

**InGermany** — это мультиязычное офлайн iOS-приложение-путеводитель для мигрантов, студентов и новых жителей Германии. Содержит структурированные статьи, категории, карту, PDF и рейтинг, с прицелом на расширение (API, Firebase, комментарии).

---

### ⚙️ Используемые технологии

* SwiftUI + MVVM
* iOS 17, Dark Mode
* AppStorage для настроек
* EnvironmentObject / ObservableObject
* Локальные JSON-файлы (данные статей, категорий, локаций)
* Manual JSON Decoding
* ShareLink (поделиться статьёй)
* NavigationView / TabView
* UserDefaults для хранения избранного и рейтингов

---

### 🗂 Структура проекта

#### Core

* `InGermanyApp.swift` — точка входа, инициализация `FavoritesManager` и `LocalizationManager`
* `ContentView.swift` — основной `TabView` с навигацией по вкладкам: Home, Search, Favorites, Categories, Settings

#### Views

* `HomeView.swift` — домашний экран, разделы: полезное (карта), избранное, все статьи
* `SearchView.swift` — поиск по тексту, категориям и тегам (включает фильтр по тегам)
* `FavoritesView.swift` — избранные статьи, сохранённые в `UserDefaults`
* `CategoriesView.swift` — список категорий с иконками
* `ArticlesByTagView.swift` — список статей по выбранному тегу
* `ArticleView.swift` — полная статья, кнопка ShareLink, рейтинг, похожие статьи по `categoryId`
* `PDFViewer.swift` — встроенный просмотр PDF-документа
* `MapView.swift` — карта локаций из `locations.json`
* `SettingsView.swift` — выбор языка, тёмной темы
* `AboutView.swift` — информация об авторе

#### Models

* `Article.swift` — модель статьи: id, title (dict), content (dict), categoryId, tags, pdfFileName
* `Category.swift` — модель категории: id, icon, localizedName (dict)
* `Location.swift` — модель локации: название, координаты, описание

#### Services

* `DataService.swift` — загрузка JSON-файлов: articles, categories, locations
* `FavoritesManager.swift` — управление избранными (add/remove, сохранение в UserDefaults)
* `RatingManager.swift` — хранение рейтингов статей в UserDefaults (по id)
* `ShareService.swift` — функция копирования и расшаривания статьи

#### Utils

* `LocalizationManager.swift` — управление языком приложения (AppStorage key: `selectedLanguage`)
* `CategoryManager.swift` — синглтон для доступа к категориям по ID
* `Theme.swift`, `Animations.swift` — визуальные настройки (цвета, анимации)

#### Resources

* `articles.json`, `categories.json`, `locations.json` — локализованные данные
* `PDFs/` — документы статей (по ключу `pdfFileName` в статье)
* `GoogleService-Info.plist` — подключение к Firebase (не используется в текущей версии)

---

### 📌 Типы и структура данных

#### Article (из `articles.json`)

```json
{
  "id": "UUID",
  "title": { "ru": "...", "en": "...", "de": "...", "tj": "..." },
  "content": { "ru": "...", "en": "...", "de": "...", "tj": "..." },
  "categoryId": "UUID",
  "tags": ["string"],
  "pdfFileName": "string (опционально)"
}
```

#### Category (из `categories.json`)

```json
{
  "id": "UUID",
  "icon": "systemImage",
  "localizedName": { "ru": "...", "en": "...", "de": "...", "tj": "..." }
}
```

#### Location (из `locations.json`)

```json
{
  "id": "UUID",
  "title": "string",
  "latitude": Double,
  "longitude": Double,
  "description": { "ru": "...", "en": "...", "tj": "..." }
}
```

---

### 💬 Взаимодействие с ИИ

**Пожалуйста, соблюдай следующие правила при генерации кода и советов:**

1. **Я могу предоставить**: любой файл проекта, скриншот экрана телефона, вывод команды git, содержимое Xcode. Проси это, если не уверен в текущем состоянии проекта.
2. **Отдавай предпочтение**: полной версии файлов при генерации. Если речь не о крошечном фрагменте — генерируй весь файл, чтобы избежать ошибок компиляции.
3. **Сохраняй стиль**: соответствуй архитектуре проекта, используй существующие ViewModels, ObservableObject, JSON и логику сохранения.
4. **Если не знаешь** — спрашивай. Не придумывай код, если не знаешь точной структуры или типа.
5. **Все статьи должны быть локализованы** на 3 языка: RU / EN / TJ.

---

### 📈 Roadmap (продолжение)

* [ ] Интеграция Firebase или Supabase для хранения данных (замена JSON)
* [ ] Авторизация (OAuth / Firebase Auth)
* [ ] Экспорт данных в CSV/PDF
* [ ] Загрузка PDF и изображений
* [ ] Загрузка новых статей из админки
* [ ] Unit-тесты моделей (Article, RatingManager и др.)
* [ ] Offline-first стратегия и синхронизация

---

Документ актуален на: **v1.4.2-related**, дата: **16.09.2025**
# AI_CONTEXT.md — InGermany Project (SwiftUI, iOS)

📦 **Project Title:** InGermany  
🧑‍💻 **Developer:** Umed Sabzaev  
📅 **Last Updated:** September 16, 2025  
🔖 **Version:** v1.4.2-related  
🌐 **Repository:** https://github.com/UmedTJK/InGermany  

---

## 🧭 Project Purpose

InGermany — это мультиязычный справочник о жизни в Германии. Приложение локально отображает статьи, категории и геолокации. Поддерживает избранное, рейтинги, поиск, тёмную тему, фильтрацию по тегам и мультиязычность (RU, EN, TJ).

---

## 📂 Project Structure Overview

```
InGermany/
├── Core/
│   ├── ContentView.swift         # Основной контейнер с TabView
│   └── InGermanyApp.swift        # Точка входа, environmentObjects
│
├── Views/                        # Все экраны
│   ├── HomeView.swift            # Главная страница со всеми статьями
│   ├── ArticleView.swift         # Детальный просмотр статьи
│   ├── SearchView.swift          # Поиск по статьям и категориям
│   ├── FavoritesView.swift       # Избранные статьи
│   ├── CategoriesView.swift      # Список категорий
│   ├── ArticlesByCategoryView.swift # Статьи по категории
│   ├── ArticlesByTagView.swift   # Статьи по тегу
│   ├── MapView.swift             # Карта локаций (locations.json)
│   ├── SettingsView.swift        # Язык, тема и др.
│   ├── AboutView.swift           # О приложении
│   └── Components/*.swift        # Отдельные блоки UI (ArticleRow, TagFilter и др.)
│
├── Models/
│   ├── Article.swift             # Структура статьи
│   ├── Category.swift            # Структура категории
│   ├── Location.swift            # Структура местоположений для карты
│   └── RatingManager.swift       # Хранение оценок пользователя
│
├── Services/
│   ├── DataService.swift         # Загрузка JSON-файлов
│   ├── CategoryManager.swift     # Управление категориями
│   └── FavoritesManager.swift    # Логика избранного
│
├── Resources/
│   ├── articles.json             # Статьи (локально)
│   ├── categories.json           # Категории
│   └── locations.json            # Геолокации
```

---

## 🔢 Models — Типы передаваемых данных

### Article
```swift
struct Article: Identifiable, Codable {
    let id: String
    let title: [String: String]
    let content: [String: String]
    let categoryId: String
    let tags: [String]
}
```

### Category
```swift
struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]
    let icon: String
}
```

### Location
```swift
struct Location: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
}
```
История коммитов:
sumtjk@SUMs-MacBook-Air InGermany % git log --oneline --graph --decorate
* 575da1d (HEAD -> main, tag: v1.4.3-docs, origin/main) docs: обновлён AI_CONTEXT.md — актуализирована структура, типы данных и советы
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
* f2f4105 docs: обновлён README — добавлены реализованные фичи (тёмная тема, изб:


## 🌍 Localization

- AppStorage используется для хранения выбранного языка (`selectedLanguage`)
- Все строки статей и категорий — словари по языку (`[String: String]`)
- Поддерживаемые языки: `ru`, `en`, `tj`

---

## 📊 View Parameters (примеры)

### `ArticleView`
```swift
ArticleView(
    article: Article,
    allArticles: [Article],
    favoritesManager: FavoritesManager
)
```

### `FavoritesView`
```swift
FavoritesView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

### `SearchView`
```swift
SearchView(
    favoritesManager: FavoritesManager,
    articles: [Article]
)
```

---

## 🛠️ Service Overview

### DataService
```swift
func loadArticles() -> [Article]
func loadCategories() -> [Category]
func loadLocations() -> [Location]
```

### FavoritesManager
- @Published `favoriteIDs: Set<String>`
- `toggleFavorite(article:)`
- `isFavorite(article:)`
- `favoriteArticles(from:)`

### RatingManager (singleton)
- Хранит и возвращает рейтинг статьи (`1...5`)
- `rating(for: articleId: String) -> Int`
- `setRating(_: Int, for articleId: String)`

---

## 📌 Советы при работе с AI

1. Я готов предоставить любой файл проекта, ответ git-команды, скриншот с телефона или Xcode для повышения точности.
2. Желательно, чтобы AI всегда отправлял **полную версию файлов**, кроме случаев точечных изменений.
3. Все `View` используют параметры: `Article`, `[Article]`, `FavoritesManager`, `selectedLanguage`.
4. Все строки статей и категорий — словари по языку (`[String: String]`). Не путать с `String`.

---

## 🧱 Особенности проекта

- ❌ Не используется Firebase (библиотеки загружены, но не активны)
- ✅ Реализована поддержка избранного
- ✅ Поддержка рейтинга (1–5)
- ✅ Поддержка тёмной темы
- ✅ Теги, категории, мультиязык
- ✅ Локальные JSON-файлы (без сетевых запросов)
- ⏳ Планируется: подключение Supabase/Firebase, загрузка PDF, авторизация, синхронизация

---

_Этот файл должен использоваться как основной справочник для всех AI-асистов и разработчиков._
<<<СОДЕРЖАНИЕ ДОКУМЕНТА AI\_CONTEXT.md БЕЗ ИЗМЕНЕНИЙ>>>

---

### 🤖 Инструкция для ИИ-ассистентов (ChatGPT, Copilot и др.)

Чтобы советы и код были максимально полезны и работали без ошибок, учитывайте следующее:

1. **Контекст доступен** — вы читаете `AI_CONTEXT.md`, актуальный на момент тега `v1.4.3-docs`. Вся структура проекта, типы данных, модули, логика навигации и зависимости описаны выше.

2. **Файлы и скриншоты**: Я (Умед) готов предоставить:

   * любой файл из проекта (`.swift`, `.json`, `.xcodeproj`, и др.),
   * любой результат команды Git (`git log`, `git status`, `git show`, `git diff`, и др.),
   * скриншот из приложения на iPhone,
   * скриншот структуры проекта в Xcode.
     Попросите, если нужно что-то уточнить — предоставлю мгновенно.

3. **Типы данных**: Давайте только такой код, который:

   * точно соответствует типам моделей (например, `Article`, `Category`, `Location`),
   * не требует вымышленных свойств или методов (если их нет — укажите, что нужно добавить),
   * учитывает использование `@AppStorage`, `@ObservedObject`, `@State`, `@EnvironmentObject`, и `@Binding` в зависимости от контекста.

4. **Полные версии кода**: Предпочтение всегда — полной версии файла (если изменяется 1+ строк). Частичный фрагмент только если правка точечная (1-2 строки).

5. **Версионность**: Если вы предлагаете изменение — желательно указывать, к какому тегу или версии оно может относиться (`v1.4.3-docs` и далее).

6. **UI и UX**: Учитывайте, что дизайн минималистичный и под iOS 17+. Используется SwiftUI. Желательно предлагать:

   * мягкие тени, закругления (`cornerRadius(12)` и т.п.),
   * разделение логики на `Views`, `Components`, `Managers`, `Services`,
   * соблюдение iOS Human Interface Guidelines.

---

Спасибо! Вы — часть умного рабочего процесса 💡
