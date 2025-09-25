# InGermany · AI_CONTEXT_v2.md

> Единый контекст для ИИ-агентов. Задача — обеспечить моментальное понимание проекта и выпуск **релевантного, безопасного и соответствующего стандартам** кода. Документ публикуется в репозитории и прикладывается ко всем запросам к ИИ-агентам.

---

## 0) Мета

* **Проект:** InGermany (iOS, SwiftUI, iOS 17+)
* **Репозиторий:** [https://github.com/UmedTJK/InGermany](https://github.com/UmedTJK/InGermany)
* **Локальный путь:** `~/Desktop/InGermany`
* **Ветка по умолчанию:** `main`
* **CI/Lint:** SwiftLint (локально), Xcode build
* **Языки контента:** ru / en / tj / de (локализация через словари)
* **Цель:** showcase-приложение для портфолио (App Store-стиль UI), офлайн-first + обновление данных из GitHub Pages

---

## 1) Принципы (обязательны для кода и ответов ИИ)

1. **Безопасность и надёжность прежде фич**.
2. **Прозрачная актуальность**: проверка `git status` и структуры проекта.
3. **Один шаг = один коммит** (Conventional Commits).
4. **Строгие контракты данных** (см. §3).
5. **Concurrency-чистота**.
6. **UI = Apple HIG**.
7. **Документируемое изменение**.

---

## 2) Архитектура и структура проекта

* **Core/**: `InGermanyApp.swift`, `ContentView.swift`
* **Models/**: `Article.swift`, `Category.swift`, `Location.swift`
* **Services/**: `DataService.swift`, `NetworkService.swift`, `ShareService.swift`, `AuthService.swift`
* **Utils/**: `LocalizationManager.swift`, `CategoryManager.swift`, `CategoriesStore.swift`, `ReadingTimeCalculator.swift`, `ExportToPDF.swift`, `Theme.swift`, `Animations.swift`, `CardSize.swift`, `Color+Hex.swift`, `TextSizeManager.swift`
* **Views/**: `HomeView`, `SearchView`, `FavoritesView`, `CategoriesView`, `ArticlesByCategoryView`, `ArticlesByTagView`, `ArticleDetailView`, `SettingsView`, `AboutView`, `MapView`
* **Views/Components/**: `ArticleCardView`, `ArticleRow`, `ArticleMetaView`, `ArticleCompactCard`, `FavoriteCard`, `RecentArticleCard`, `ToolCard`, `EmptyFavoritesView`, `CategoryFilterButton`, `TagFilterView`, `TextSizeSettingsPanel`, `ReadingProgressBar`, `ReadingProgressView`, `CircularReadingProgress`, `PDFViewer`
* **Resources/**: `articles.json`, `categories.json`, `locations.json`
* **Docs/**: `Docs/AI_CONTEXT_v2.md`, `Docs/CHANGELOG.md`, `Docs/PROMPTS_FOR_AI_AGENTS.md`, `Docs/Git_Mini_Guide.md`, `Docs/CLEAN_CODE_CHECKLIST.md`, `Docs/git_snapshot.md`, `Docs/project_tree.md`
* **Docs (архив)**: `Docs/PROJECT_STRUCTURE.md`, `Docs/Project_Brief.docx`
* **Корень**: `.swiftlint.yml`, `README.md`, `update.sh`

---

## 2a) Структура проекта (актуальная)

Полное дерево проекта хранится в файле: `Docs/project_tree.md`

> ⚠️ Обновляется вручную командой:
>
> ```bash
> cd ~/Desktop/InGermany
> tree -L 3 > Docs/project_tree.md
> ```

---

## 2b) Потоки данных и хранение

* **Articles**: JSON → Codable `Article`. Хранение: DataService → Cache / Bundle / Network.
* **Categories**: JSON → Codable `Category`. Хранение через CategoryManager + CategoriesStore.
* **Locations**: JSON → Codable `Location`. Для карты.
* **Favorites**: `@AppStorage("favoriteArticles")` как JSON `Set<String>`.
* **Rating**: `UserDefaults` (`rating_<articleId>`).
* **ReadingHistory**: `@AppStorage("readingHistory")` JSON → массив `ReadingHistoryEntry`.
* **Text size**: `UserDefaults` (`textSize` + toggle).

---

## 2c) Публичные интерфейсы

2c) Публичные интерфейсы

Models

Article: id, title/content локализованные, categoryId, tags, pdfFileName?, createdAt/updatedAt, image?. Методы: localizedTitle, localizedContent, formattedCreatedDate, readingTime.

Category: id, name локализованные, icon (SF Symbol), colorHex.

Location: id, name, latitude, longitude.

Services

DataService (actor): loadArticles(), loadCategories(), loadLocations(), refreshData(), clearCache(), getLastDataSource().

NetworkService: loadJSON<T>(), loadJSONSync<T>(), clearCache().

ShareService: shareArticle(_:language:).

AuthService: (заглушка).

Managers

FavoritesManager: isFavorite(id:), toggleFavorite(id:), favoriteArticles(from:).

RatingManager: rating(for:), setRating(_:for:).

ReadingHistoryManager: addReadingEntry, recentlyReadArticles, isRead, lastReadDate, totalReadingTimeMinutes, totalArticlesRead, clearHistory.

ReadingTracker: startReading, finishReading, currentReadingTime.

CategoryManager (actor): loadCategories(), allCategories(), category(for:), refreshCategories().

CategoriesStore: bootstrap(), refresh(), category(for:), categoryName(for:).

TextSizeManager: Published fontSize (Double), toggle, presetSizes, resetToDefault(), currentFont.

Utils

LocalizationManager: getTranslation(key:lang:).

ReadingTimeCalculator: estimateReadingTime(for:lang:), formatReadingTime(_:lang:).

ExportToPDF: export(title:content:fileName:).

Theme: card/tint/background colors, spacing.

Animations: cardStyle, scaleOnAppear, shimmer, slideInAnimation, haptic feedback.

CardSize: width(for:), height(for:screenHeight:screenWidth:).

Color+Hex: init?(hex:).

UI Components

ArticleCardView: article → карточка.

ArticleCompactCard: article → горизонтальная карточка.

ArticleRow: article → строка списка.

ArticleMetaView: article (+ CategoriesStore env).

FavoriteCard: article → избранное.

RecentArticleCard: article → компакт.

ToolCard: (title, systemImage, color).

EmptyFavoritesView: (hasFilters, lang, translationFn).

CategoryFilterButton: (title, isSelected, systemImage, action).

TagFilterView: (tags, onTagSelected).

TextSizeSettingsPanel: экран настроек текста.

ReadingProgressBar / ReadingProgressView / CircularReadingProgress: прогресс чтения.

PDFViewer: fileName → PDFKit.

CategoriesView: categories + articles + favoritesManager.

ArticlesByTagView: tag + articles + favoritesManager.

ArticleDetailView: article + favoritesManager, PDF, избранное.

---

## 5) Рабочий цикл ИИ-агента

```bash
cd ~/Desktop/InGermany
swiftlint lint --strict || true
git status
git log --oneline --graph -n 10
```

* Если есть незакоммиченные правки → спросить решение.
* Коммит только Conventional Commits.
* Всегда пуш в GitHub.

Снимок git-истории смотри: `Docs/git_snapshot.md`

---

## 6) Roadmap

См. раздел Roadmap в README.md и CHANGELOG.md.
Основные планы: улучшение UI, поддержка сетевой загрузки, тесты ViewModel, расширение контента.

---

## 7) Обновление документа

* Меняется модель/интерфейс → правим §2b/2c.
* Фиксируем в `Docs/CHANGELOG.md`.
* Коммит: `docs(context): обновлён AI_CONTEXT_v2`.
