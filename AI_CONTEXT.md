# 🤖 AI_CONTEXT.md

## 🧠 Назначение файла

Этот документ предназначен для ИИ (включая ChatGPT), чтобы понимать весь проект **InGermany** без необходимости повторной загрузки исходных файлов. Он содержит структурированное описание компонентов, логики, типов данных, текущего состояния и roadmap.

---

## 📦 Общая информация о проекте

* **Название:** InGermany
* **Платформа:** iOS (SwiftUI)
* **Минимальная версия iOS:** 17+
* **Тип:** Offline-first справочник для мигрантов, студентов и семей в Германии
* **Языки интерфейса:** Русский, Английский, Таджикский
* **Формат данных:** JSON (локально), в планах — Firebase/Supabase
* **Тема:** Светлая/тёмная (через @AppStorage)
* **Избранное:** через @AppStorage("favoriteArticles") — Set<String>

---

## 🧱 Архитектура проекта (Xcode структура)

```
InGermany/
├── Core/
│   ├── InGermanyApp.swift
│   └── ContentView.swift
│
├── Models/
│   ├── Article.swift
│   └── Category.swift
│
├── Views/
│   ├── HomeView.swift
│   ├── CategoriesView.swift
│   ├── ArticlesByCategoryView.swift
│   ├── ArticleView.swift
│   ├── ArticleDetailView.swift
│   ├── FavoritesView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   └── Components/
│       └── ArticleRow.swift
│
├── Services/
│   ├── DataService.swift
│   ├── ShareService.swift
│   └── AuthService.swift (заготовка)
│
├── Utils/
│   ├── CategoryManager.swift
│   ├── LocalizationManager.swift
│   ├── Theme.swift
│   └── Animations.swift
│
├── Resources/
│   ├── articles.json
│   └── categories.json
│
├── Screenshots/
├── update.sh
├── README.md
└── AI_CONTEXT.md
```

---

## 🔢 Типы данных и зависимости компонентов

### 📄 Модели

```swift
struct Article: Identifiable, Codable {
    let id: String
    let title: [String: String]
    let content: [String: String]
    let categoryId: String
    let tags: [String]
}

struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]
    let icon: String
}
```

---

## 💾 Примеры JSON-объектов

```json
// Пример статьи
{
  "id": "1234-5678",
  "title": { "ru": "Пример", "en": "Example", "tj": "Мисол" },
  "content": { "ru": "...", "en": "...", "tj": "..." },
  "categoryId": "abcd",
  "tags": ["банк", "виза"]
}

// Пример категории
{
  "id": "abcd",
  "name": { "ru": "Финансы", "en": "Finance", "tj": "Молия" },
  "icon": "banknote"
}
```

---

## 🔄 Поток данных (Data Flow)

- `InGermanyApp.swift` → инициализация `ContentView`
- `ContentView.swift` → передаёт:
  - `articles` из `DataService.loadArticles()`
  - `categories` из `DataService.loadCategories()`
  - `favoritesManager` как `@StateObject`
- Все `Views` получают данные через пропсы
- Выбранный язык и тема — через `@AppStorage`

---

## 📦 Состояния и окружения

- `@AppStorage("selectedLanguage") var selectedLanguage: String`
- `@AppStorage("favoriteArticles") var favoriteIDs: Set<String>`
- `FavoritesManager`: `ObservableObject`
- `Theme`: через `@AppStorage("isDarkMode")`

---

## 🧭 Обзор экранов (Views)

- `HomeView` — показывает список последних и избранных статей
- `CategoriesView` — список всех категорий
- `ArticlesByCategoryView` — статьи по выбранной категории
- `ArticleView` — обёртка для перехода
- `ArticleDetailView` — полный текст статьи + кнопки
- `SearchView` — поиск по тексту, заголовкам, тегам
- `FavoritesView` — избранные статьи
- `SettingsView` — смена языка и темы

---

## ✅ Реализовано:

* [x] Мультиязычность через `@AppStorage("selectedLanguage")`
* [x] Избранное через `FavoritesManager` и `@AppStorage("favoriteArticles")`
* [x] Загрузка статей и категорий из JSON
* [x] Поиск по статьям, содержанию и категориям
* [x] Поделиться статьёй (`ShareService` + `UIActivityViewController`)
* [x] Переключение светлой/тёмной темы (`Theme.swift`)
* [x] Навигация по категориям и тегам

---

## ⛔ Пока не реализовано:

* [ ] Firebase / Supabase
* [ ] Поддержка PDF
* [ ] Apple Maps
* [ ] Unit-тесты
* [ ] Backend API

---

## 🛣 Roadmap (осень 2025)

* [ ] ☁️ Firebase для хранения статей и избранного
* [ ] 📄 Открытие и прикрепление PDF к статьям
* [ ] 🗺 Карта: посольства, Bürgeramt и др.
* [ ] 🧪 Тесты (Favorites, Search)
* [ ] 🎨 Интеграция `Theme.swift` с `@Environment`
* [ ] 📊 Калькуляторы (доходы, расходы)
* [ ] 🎥 Видео-демо

---

## 🤝 Рекомендации для ИИ

✅ Используй `@AppStorage` только для языка, темы, избранного  
✅ Все Views получают данные через пропсы  
✅ Строго следуй описанным структурам `Article`, `Category`  
❌ Не создавай глобальные переменные  
❌ Не внедряй Firebase пока он не активирован  

---

## 📅 Последнее обновление: 15 September 2025
