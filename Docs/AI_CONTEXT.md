# AI_CONTEXT.md

## 1. Общая информация

**Название проекта:** InGermany  
**Тип:** iOS-приложение (SwiftUI)  
**Цель:** Мультиязычный справочник для экспатов в Германии: статьи, инструменты, карты, избранное.  
**Разработчик:** @UmedTJK (GitHub)  
**Платформа:** iOS 17+, Swift 5.9  
**Текущая версия:** v1.13.4  
**Архитектура:** MVVM + Repositories + DI через AppContainer  
**Поддержка тёмной темы:** ✅  
**Поддержка мультиязычности:** ✅ (см. ниже)

## 2. Архитектура и технологии

- **UI Framework:** SwiftUI
- **Архитектурные принципы:** MVVM, SOLID, DI через конструктор
- **DI-контейнер:** `AppContainer.swift` (синглтон `.shared`)
- **Управление состоянием:** `@ObservableObject`, `@Published`, `@AppStorage`, `@EnvironmentObject`
- **Работа с JSON:** локально и через GitHub Pages
- **Локализация:** кастомный `LocalizationManager`
- **Версионирование:** Git + автоматическая генерация тега и CHANGELOG
- **CI/CD:** отсутствует (возможно добавить позднее)

## 3. Структура проекта (основные директории и их назначение)

```

InGermany/
├── Core/              # Точка входа и DI-контейнер
├── Models/            # Модели: Article, Category, Location
├── ViewModels/        # ViewModel-классы (один на каждый экран)
├── Views/             # SwiftUI-вьюшки (включая Секции и Компоненты и Cards)
├── Managers/          # Сервисные менеджеры (TextSize, Favorites и др.)
├── Services/          # Репозитории, сетевые и локальные сервисы
├── Resources/         # Локальные JSON-файлы: articles.json и др.
├── Docs/              # Документация: AI_CONTEXT.md, CHANGELOG.md и т.п.
└── Scripts/           # Скрипты релизов, генерации тегов, changelog

```

## 4. Компоненты

### 🔹 Views (основные экраны)
- `HomeView.swift`
- `SearchView.swift`
- `FavoritesView.swift`
- `CategoriesView.swift`
- `ArticleDetailView.swift`
- `SettingsView.swift`
- `AboutView.swift`
- `MapView.swift`
- `ArticlesByTagView.swift`
- `ArticlesByCategoryView.swift`
- `PDFViewer.swift`

### 🔹 ViewModels
- `HomeViewModel.swift`
- `SearchViewModel.swift`
- `FavoritesViewModel.swift`
- `CategoriesViewModel.swift`
- `SettingsViewModel.swift`
- `AboutViewModel.swift`
- `LocationsViewModel.swift`
- `ArticleDetailViewModel.swift`
- `ArticleRowViewModel.swift`
- `PDFViewerViewModel.swift`

### 🔹 Managers (10 из 10)
- `TextSizeManager.swift`
- `FavoritesManager.swift`
- `CategoryManager.swift`
- `RatingManager.swift`
- `ReadingHistoryManager.swift`
- `ReadingProgressHelper.swift`
- `ReadingProgressTracker.swift`
- `ReadingTimeCalculator.swift`
- `ReadingTimeTracker.swift`
- `LocalizationManager.swift`

### 🔹 Services / Repositories
- `ArticlesRepositoryProtocol.swift`
- `ArticlesRepositoryImpl.swift`
- `CategoriesRepositoryProtocol.swift`
- `DataService.swift`
- `DefaultsStore.swift`
- `AuthService.swift`
- `NetworkService.swift`
- `ShareService.swift`
- `ExportToPDF.swift`

### 🔹 Компоненты и Секции
- `ArticleCardView`, `ArticleMetaView`, `ArticleRow`
- `StarRatingView`, `ReadingProgressBar`, `LanguagePickerView`
- `TextSizeSettingsPanel`, `FavoriteCard`, `TagFilterView`
- `FavoritesSection`, `RecentlyReadSection`, `CategorySection`
- `AllArticlesSection`, `UsefulToolsSection`

## 5. Интеграция зависимостей (Dependency Injection)

- Используется кастомный DI-контейнер: `AppContainer`
- DI через `.shared` либо `@EnvironmentObject`
- Создание зависимостей через `makeXYZViewModel()`
- Все ViewModels инжектируются вручную (без SwiftUI `@StateObject`)
- Менеджеры и репозитории реализованы как `ObservableObject` или синглтоны
- Протоколы: `ArticlesRepositoryProtocol`, `CategoriesRepositoryProtocol` и др.


## 6. Unit‑тесты и покрытие

В проекте используется модульное покрытие юнит‑тестами (XCTest) по слоям архитектуры: Models, ViewModels, Managers, Services, Helpers.  
Все тесты структурированы в каталоге `InGermanyTests/` и разделены по ответственности. Также присутствуют mock‑данные и UI‑тесты.

### 📁 Структура тестов

InGermanyTests/
├── Mocks/                         // Заглушки и мок‑сервисы
├── Models/
│   ├── ArticleTests.swift
│   ├── CategoryTests.swift
│   └── LocationTests.swift
├── Resources/
│   ├── sample_articles.json       // Тестовые данные
│   └── sample_categories.json
├── UI/
│   └── AppUITests.swift           // UI‑тесты (XCTest/UI)
├── Unit/
│   ├── Helpers/
│   │   ├── ReadingProgressTrackerTests.swift
│   │   └── ReadingTimeCalculatorTests.swift
│   ├── Managers/
│   │   ├── CategoryManagerTests.swift
│   │   ├── FavoritesManagerTests.swift
│   │   ├── RatingManagerTests.swift
│   │   └── ReadingHistoryManagerTests.swift
│   ├── Services/
│   │   ├── ArticlesRepositoryImplTests.swift
│   │   ├── DataServiceTests.swift
│   │   └── NetworkServiceTests.swift
│   └── ViewModels/
│       ├── AboutViewModelTests.swift
│       ├── ArticleDetailViewModelTests.swift
│       ├── ArticleRowViewModelTests.swift
│       ├── CategoriesViewModelTests.swift
│       ├── FavoritesViewModelTests.swift
│       ├── HomeViewModelTests.swift
│       ├── SearchViewModelTests.swift
│       └── SettingsViewModelTests.swift

```

### 🧪 Покрытие и приоритеты

| Компонент          | Тесты              | Статус       |
|--------------------|--------------------|--------------|
| ViewModels         | ✅ 8/8              | Хорошее      |
| Managers           | ✅ 4/5              | Хорошее      |
| Services           | ✅ 3/5              | Удовлетворит.|
| Models             | ✅ 3/3              | Полное       |
| Helpers            | ✅ 2/2              | Полное       |
| UI‑тесты           | ✅ AppUITests       | Есть         |
| Mocks              | ✅ Используются     | Частично     |

### 🧩 Возможные улучшения

- [ ] Добавить тесты для `DefaultsStore`, `AuthService`, `ExportToPDF`, `ShareService`
- [ ] Расширить мок‑объекты (`MockDefaultsStore`, `MockAuthService`)
- [ ] Добавить UI snapshot‑тесты (например, для `ArticleCardView`)
- [ ] Проверить, что все `.ViewModelTests` охватывают happy и error path
- [ ] Обновить README.md с секцией про тестирование и `xcodebuild test`
```


## 7. Дальнейшие шаги

- [ ] Создать `ReadingStats.swift` для статистики чтения
- [ ] Создать `AppError.swift` для централизованной обработки ошибок
- [ ] Добавить enum `AppFeature` для фичей и аналитики
- [ ] Покрыть `Managers` и `Services` юнит-тестами
- [ ] Добавить Unit Tests для ViewModels
- [ ] Подключить SwiftLint + скрипт авто-проверки
- [ ] Включить basic accessibility labels
- [ ] Улучшить Theme.swift (адаптация для iPad, Vision, etc.)
- [ ] Добавить логирование и crash reporting

## 8. Использование с AI-агентами

Перед генерацией кода:
1. Архитектура — строго MVVM + Repositories + HIG
2. Всегда использовать `protocol` для `Service`/`Repository`
3. Использовать конструкторный DI (`AppContainer` и `.shared`)
4. Поддержка iOS 17+, Swift 5.9 — не оставлять `warning`
5. Добавлять юнит-тесты с моками (`happy + error path`)
6. Без `force unwrap`; ошибки обрабатывать или пробрасывать
7. Локализовать все строки через `LocalizationManager`
8. Добавлять базовые `accessibilityLabel`
9. Обновлять `CHANGELOG.md` и `AI_CONTEXT.md` при изменении контрактов
10. Перед внесении изменении просить пользователя уточнить гит-ветку, и поддержат процесс гит коммитов

