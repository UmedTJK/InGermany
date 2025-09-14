//
//  PROJECT_STRUCTURE.md
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

# 📱 InGermany – Техническое описание проекта

## 🔹 Общая идея
**InGermany** — это iOS-приложение на **SwiftUI**, которое отображает справочные статьи по жизни в Германии.
Приложение работает полностью офлайн (данные берутся из `articles.json` и `categories.json` в папке `Resources`).

Функционал:
- Просмотр статей по категориям
- Поиск по статьям
- Избранное (Favorites)
- Настройки (выбор языка и тема оформления)
- Поделиться статьей

---

## 🔹 Архитектура проекта
Приложение построено по **MVVM-подходу**, но в упрощённой форме:
- **Models** – структуры данных (`Article`, `Category`)
- **Views** – экранные компоненты на SwiftUI
- **Services** – работа с данными, шаринг, авторизация (пока базовая)
- **Utils** – вспомогательные утилиты (тема, анимации, локализация)
- **Resources** – JSON-файлы с данными (категории, статьи), а также ассеты

---

## 🔹 Основные папки и их назначение

### 1. **Core**
- `InGermanyApp.swift` – точка входа в приложение (App struct)
- `ContentView.swift` – главный контейнер с `TabView` (вкладки: Home, Categories, Search, Favorites, Settings)

---

### 2. **Views**
Каждый экран реализован как отдельный SwiftUI View:
- `HomeView.swift` – главная страница
- `CategoriesView.swift` – список категорий
- `ArticlesByCategoryView.swift` – статьи внутри категории
- `ArticleView.swift` – отдельная статья
- `ArticleDetailView.swift` – расширенный экран статьи
- `FavoritesView.swift` – избранное
- `SettingsView.swift` – настройки
- `SearchView.swift` – поиск

**Компоненты**:
- `ArticleRow.swift` – карточка статьи (переиспользуемый элемент списка)
- `FavoritesManager.swift` – логика работы с избранным

---

### 3. **Models**
- `Article.swift` – модель статьи (`id`, `title`, `content`, `categoryId`, `tags`)
- `Category.swift` – модель категории (`id`, `name`, `icon`)

---

### 4. **Services**
- `DataService.swift` – загрузка данных из JSON (`articles.json`, `categories.json`)
- `ShareService.swift` – системное окно “Поделиться”
- `AuthService.swift` – задел под авторизацию (может быть расширен)

---

### 5. **Utils**
- `Animations.swift` – готовые анимации (например, плавный fade-in)
- `Theme.swift` – цвета, шрифты, стили
- `LocalizationManager.swift` – мультиязычность (ru, en, de)
- `CategoryManager.swift` – управление категориями

---

### 6. **Resources**
- `articles.json` – список статей
- `categories.json` – список категорий с иконками
- `Assets.xcassets` – картинки и иконки
- `Preview Content` – моковые данные для Xcode Preview

---

## 🔹 Типы данных

### Article (пример)
```json
{
  "id": "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "title": {
    "ru": "Как открыть банковский счёт в Германии",
    "en": "How to open a bank account in Germany",
    "de": "Wie eröffnet man ein Bankkonto in Deutschland"
  },
  "content": {
    "ru": "Чтобы открыть банковский счёт, нужен паспорт...",
    "en": "To open a bank account, you usually need a passport...",
    "de": "Um ein Bankkonto zu eröffnen, benötigen Sie..."
  },
  "categoryId": "11111111-1111-1111-1111-aaaaaaaaaaaa",
  "tags": ["банк", "счёт", "финансы"]
}
Category (пример)
{
  "id": "11111111-1111-1111-1111-aaaaaaaaaaaa",
  "name": {
    "ru": "Финансы",
    "en": "Finance",
    "de": "Finanzen"
  },
  "icon": "💰"
}

🔹 Текущая логика

При запуске приложения загружаются articles.json и categories.json.

Пользователь видит TabView с 5 экранами.

Вкладка Categories → список категорий с иконками → переход в список статей.

Вкладка Search → поиск по всем статьям.

Вкладка Favorites → статьи, добавленные в избранное.

Вкладка Settings → выбор языка и (в будущем) темы.

Локализация работает через LocalizationManager.
