# InGermany · AI_CONTEXT.md

> Единый контекст для ИИ-агентов. Задача — обеспечить моментальное понимание проекта и выпуск **релевантного, безопасного и соответствующего стандартам** кода. Документ публикуется в репозитории и прикладывается ко всем запросам к ИИ-агентам.

---

## 0) Мета

* **Проект:** InGermany (iOS, SwiftUI, iOS 17+)  
* **Репозиторий:** [https://github.com/UmedTJK/InGermany](https://github.com/UmedTJK/InGermany)  
* **Локальный путь:** `~/Desktop/InGermany`  
* **Ветка по умолчанию:** `main` (активная может быть фича-ветка, см. `Docs/git_snapshot.md`)  
* **CI/Lint:** SwiftLint (локально), Xcode build  
* **Языки контента:** ru / en / tj / de (локализация через словари)  
* **Цель:** showcase-приложение для портфолио (App Store-стиль UI), офлайн-first + обновление данных из GitHub Pages  

---

## 1) Принципы

1. **Безопасность и надёжность прежде фич.**  
2. **Прозрачная актуальность**: сверка `git status` и структуры проекта.  
3. **Один шаг = один коммит** (Conventional Commits).  
4. **Строгие контракты данных** (§2b/2c).  
5. **Concurrency-чистота.**  
6. **UI = Apple HIG.**  
7. **Документируемое изменение.**

---

## 2) Архитектура и структура проекта

* **Core/**: `InGermanyApp.swift`, `ContentView.swift`  
* **Models/**: `Article.swift`, `Category.swift`, `Location.swift`  
* **Services/**: `DataService.swift`, `NetworkService.swift`, `ShareService.swift`, `AuthService.swift`  
* **Utils/**: `LocalizationManager.swift`, `CategoryManager.swift`, `CategoriesStore.swift`, `ReadingTimeCalculator.swift`, `ExportToPDF.swift`, `Theme.swift`, `Animations.swift`, `CardSize.swift`, `Color+Hex.swift`, `TextSizeManager.swift`  
* **Views/**: `HomeView`, `SearchView`, `FavoritesView`, `CategoriesView`, `ArticlesByCategoryView`, `ArticlesByTagView`, `ArticleDetailView`, `SettingsView`, `AboutView`, `MapView`  
* **Views/Components/**: `ArticleCardView`, `ArticleRow`, `ArticleMetaView`, `ArticleCompactCard`, `FavoriteCard`, `RecentArticleCard`, `ToolCard`, `EmptyFavoritesView`, `CategoryFilterButton`, `TagFilterView`, `TextSizeSettingsPanel`, `ReadingProgressBar`, `ReadingProgressView`, `CircularReadingProgress`, `PDFViewer`  
* **Resources/**: `articles.json`, `categories.json`, `locations.json`  
* **Docs/**: `AI_CONTEXT_v2.md`, `CHANGELOG.md`, `PROMPTS_FOR_AI_AGENTS.md`, `Git_Mini_Guide.md`, `CLEAN_CODE_CHECKLIST.md`, `git_snapshot.md`, `project_tree.md`  
* **Docs (архив)**: `PROJECT_STRUCTURE.md`, `Project_Brief.docx`  
* **Корень**: `.swiftlint.yml`, `README.md`, `update.sh`

---

## 2a) Структура проекта (актуальная)

Полное дерево проекта хранится в файле: `Docs/project_tree.md`

> ⚠️ Обновляется вручную командой:
> ```bash
> cd ~/Desktop/InGermany
> tree -L 3 > Docs/project_tree.md
> ```

---

## 2b) Потоки данных, менеджеры и хранение

### Модели

- **Article**  
  `id, title:[String:String], content:[String:String], categoryId, tags, pdfFileName?, createdAt?, updatedAt?, image?`  
  Методы: `localizedTitle`, `localizedContent`, `formattedCreatedDate`, `formattedUpdatedDate`, `readingTime`, `formattedReadingTime`.

- **Category**  
  `id, name:[String:String], icon (SF Symbol), colorHex`  
  Метод: `localizedName(for:)`.

- **Location**  
  `id, name, latitude, longitude`  
  Свойство: `coordinate: CLLocationCoordinate2D`.

### Менеджеры состояния

- **FavoritesManager**  
  `@AppStorage("favoriteArticles")` → JSON `Set<String>`  
  Методы: `isFavorite(id:)`, `toggleFavorite(id:)`, `favoriteArticles(from:)`.

- **RatingManager**  
  Хранение: `UserDefaults` (`rating_<articleId>`)  
  Методы: `rating(for:)`, `setRating(_:for:)`.

- **ReadingHistoryManager**  
  Хранение: `@AppStorage("readingHistory")` JSON массив `ReadingHistoryEntry`.  
  Методы: `addReadingEntry`, `recentlyReadArticles`, `isRead`, `lastReadDate`, `clearHistory`.  
  Ограничение: максимум 100 записей.  
  Вспомогательные: `ReadingTracker`, `ReadingStats`.

- **CategoryManager (actor)**  
  Методы: `loadCategories()`, `allCategories()`, `category(for id:)`, `category(for name:language:)`, `refreshCategories()`.

- **CategoriesStore (ObservableObject)**  
  Published: `categories:[Category]`, `byId:[String:Category]`.  
  Методы: `bootstrap()`, `refresh()`, `category(for:)`, `categoryName(for:)`.

- **TextSizeManager (ObservableObject)**  
  Хранение: `UserDefaults` (`articleFontSize`, `isCustomTextSizeEnabled`).  
  Методы: `presetSizes`, `resetToDefault()`, `currentFont`.

---

### Сервисы

- **DataService (actor)**  
  Приоритет загрузки: память → Bundle JSON → сеть.  
  Методы: `loadArticles`, `loadCategories`, `loadLocations`, `refreshData`, `clearCache`, `getLastDataSource`.

- **NetworkService**  
  Приоритет: сеть → cache (~/Library/Caches/InGermanyCache) → Bundle.  
  Методы: `loadJSON<T:Decodable>(from:)`, `loadJSONSync<T>(from:completion:)`, `clearCache`.

- **ShareService**  
  Метод: `shareArticle(_:language:)` → iOS Share Sheet.

- **AuthService**  
  Заглушка.

---

### Утилиты

- **Theme.swift** — цвета, градиенты, spacing, `sectionCardStyle()`.  
- **ReadingTimeCalculator** — оценка времени чтения (слова / скорость).  
- **ProgressBar.swift** — горизонтальный бар.  
- **LocalizationManager** — локализация UI-ключей.  
- **ExportToPDF** — экспорт статьи в PDF.  
- **Color+Hex.swift** — инициализация `Color` из HEX.  
- **CardSize.swift** — вычисление размеров карточек.  
- **Animations.swift** — стили, анимации, haptics.

---

### UI-компоненты

- **TextSizeSettingsPanel** — экран настройки текста.  
- **TagFilterView** — фильтр тегов.  
- **ReadingProgressBar / ReadingProgressView / CircularReadingProgress** — прогресс чтения.  
- **PDFViewer** — рендер PDF из Bundle.  
- **FavoriteCard** — карточка избранного.  
- **Components.swift**: `ToolCard`, `RecentArticleCard`, `EmptyFavoritesView`, `CategoryFilterButton`.  
- **Animations.swift**: `.cardStyle()`, `.scaleOnAppear()`, `.shimmer()`, haptic feedback.  
- **ArticleCardView** — карточка статьи в сетке.  
- **ArticleMetaView** — категория, даты, бейджи.  
- **ArticleRow** — строка списка статей.  
- **ArticleCompactCard** — компактная карточка.  

---

### Экраны

- **HomeView**  
  Секции: «Полезные инструменты» (MapView, PDFViewer, Random Article), «Недавно прочитанное», «Избранное», категории, «Все статьи».  
  Работает с: `favoritesManager`, `categoriesStore`, `ReadingHistoryManager`.

- **MapView**  
  Отображает `locations.json` (через DataService).  
  Toolbar: «Моё местоположение», «Обновить».

- **SearchView**  
  Поиск по тексту, тегам, категориям.  
  Использует: `TagFilterView`, `ArticleRow`.

- **SettingsView**  
  Настройки: язык, тема, размер текста, формат даты.  
  Показывает статистику чтения.  
  Раздел «О приложении» → AboutView.

- **ArticleDetailView**  
  Полный экран статьи.  
  Функции: PDF, избранное.  

- **ArticlesByTagView** — список по тегу.  
- **CategoriesView** — список категорий.  
- **FavoritesView** — избранные статьи.  
- **AboutView** — информация о проекте.  

---

## 2c) Публичные интерфейсы

> 📎 Все таблицы интерфейсов сведены по категориям: модели, сервисы, менеджеры, утилиты, UI и экраны.  
> Формат: **Класс/Файл** → метод/свойство → входные параметры → возвращает → комментарий.  
> (см. подробные таблицы в подготовленных блоках; при обновлении API фиксировать в этом разделе).

---

## 3) Ресурсы

- `Resources/articles.json`  
- `Resources/categories.json`  
- `Resources/locations.json`  
- `Assets.xcassets` (логотипы, иконки)  
- `Docs/*` (AI_CONTEXT, project_tree, git_snapshot и др.)  
- `update.sh`

---

## 4) Дорожная карта

См. Roadmap в `README.md` и `CHANGELOG.md`.  
Основные направления: улучшение UI, поддержка сетевой загрузки, unit-тесты ViewModel, расширение контента.

---

## 5) Рабочий цикл ИИ-агента

```bash
cd ~/Desktop/InGermany
swiftlint lint --strict || true
git status
git log --oneline --graph -n 10
```

- Если есть незакоммиченные правки → спросить решение.  
- Коммиты только в стиле **Conventional Commits**.  
- Пуш всегда в GitHub.  

Актуальный снимок git хранится в: `Docs/git_snapshot.md`.

---

## 6) Обновление контекста

- Меняется модель/интерфейс → обновить §2b/2c.  
- Обновляется структура → перегенерировать `Docs/project_tree.md`.  
- Новый коммит/ветка → обновить `Docs/git_snapshot.md`.  
- Все изменения фиксировать в `Docs/CHANGELOG.md`.  
- Коммит:  
  ```bash
  git commit -m "docs(context): обновлён AI_CONTEXT_v2"
  ```

