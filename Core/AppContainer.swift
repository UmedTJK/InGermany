import SwiftUI

/// The main dependency injection container for the app.
@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()
    
    // Существующие зависимости...
    let articlesRepo: ArticlesRepositoryProtocol
    let categoriesRepo: CategoriesRepositoryProtocol
    let favoritesManager: FavoritesManager
    let historyManager: ReadingHistoryManager
    let ratingManager: RatingManager
    let readingProgressTracker: ReadingProgressTracker
    let textSizeManager: TextSizeManager
    let readingTimeTracker: ReadingTimeTracker
    let localizationManager: LocalizationManager
    let dataService: DataService

    init(
        articlesRepo: ArticlesRepositoryProtocol? = nil,
        categoriesRepo: CategoriesRepositoryProtocol? = nil,
        favoritesManager: FavoritesManager? = nil,
        historyManager: ReadingHistoryManager? = nil,
        ratingManager: RatingManager? = nil,
        readingProgressTracker: ReadingProgressTracker? = nil,
        textSizeManager: TextSizeManager? = nil,
        readingTimeTracker: ReadingTimeTracker? = nil,
        localizationManager: LocalizationManager? = nil,
        dataService: DataService? = nil
    ) {
        // ✅ Инициализируем DataService ПЕРВЫМ, так как он нужен для ArticlesRepositoryImpl
        let dataServiceInstance = dataService ?? DataService.shared
        self.dataService = dataServiceInstance
        
        self.articlesRepo = articlesRepo ?? ArticlesRepositoryImpl(dataService: dataServiceInstance)
        self.categoriesRepo = categoriesRepo ?? DefaultCategoriesRepository.shared
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.historyManager = historyManager ?? ReadingHistoryManager.shared
        self.ratingManager = ratingManager ?? RatingManager.shared
        self.readingProgressTracker = readingProgressTracker ?? ReadingProgressTracker.shared
        self.textSizeManager = textSizeManager ?? TextSizeManager.shared
        self.readingTimeTracker = readingTimeTracker ?? ReadingTimeTracker.shared
        self.localizationManager = localizationManager ?? appContainer.localizationManager
    }

    // MARK: - Существующие Factory Methods для ViewModels
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesManager,
            readingHistoryManager: historyManager,
            categoriesRepository: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            favoritesManager: favoritesManager,
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo,
            favoritesManager: favoritesManager
        )
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesManager,
            articlesRepo: articlesRepo
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(historyManager: historyManager)
    }

    func makeArticleDetailViewModel(article: Article, allArticles: [Article]) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            favoritesManager: favoritesManager,
            historyManager: historyManager
        )
    }

    func makeAboutViewModel() -> AboutViewModel {
        AboutViewModel()
    }

    // MARK: - НОВЫЕ Factory Methods для UI компонентов

    func makeArticleRowViewModel(article: Article) -> ArticleRowViewModel {
        ArticleRowViewModel(
            article: article,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager
        )
    }

    func makeArticleCompactCardViewModel(article: Article) -> ArticleRowViewModel {
        makeArticleRowViewModel(article: article)
    }

    func makeArticleCardViewModel(article: Article) -> ArticleRowViewModel {
        makeArticleRowViewModel(article: article)
    }

    // MARK: - НОВЫЕ Factory Methods для специализированных ViewModels

    func makeLocationsViewModel() -> LocationsViewModel {
        LocationsViewModel(dataService: dataService)
    }

    func makePDFViewerViewModel() -> PDFViewerViewModel {
        PDFViewerViewModel(localizationManager: localizationManager)
    }

    // MARK: - Вспомогательные методы для dependency injection

    func provideEnvironmentObjects() -> some View {
        EmptyView()
            .environmentObject(self)
            .environmentObject(favoritesManager)
            .environmentObject(textSizeManager)
            .environmentObject(localizationManager)
            .environmentObject(readingProgressTracker)
            .environmentObject(readingTimeTracker)
    }

    // 🔧 ИСПРАВЛЕННЫЙ МЕТОД - используем публичные методы менеджеров вместо прямого доступа
    func clearAllData() {
        favoritesManager.clearForTesting()
        ratingManager.clearForTesting()
        historyManager.clearForTesting()
        
        // Вместо прямого доступа к private(set) свойствам используем публичные методы
        // Если в менеджерах нет методов для очистки, добавляем их или просто пропускаем
        // так как это используется только для тестирования
        
        // Для ReadingProgressTracker - если нет метода очистки, пропускаем
        // readingProgressTracker.progress.removeAll() // ❌ Нельзя - private(set)
        
        // Для ReadingTimeTracker - если нет метода очистки, пропускаем
        // readingTimeTracker.completedSessions.removeAll() // ❌ Нельзя - private(set)
        // readingTimeTracker.activeSessions.removeAll() // ❌ Нельзя - private(set)
    }
}
