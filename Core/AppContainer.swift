import SwiftUI

/// The main dependency injection container for the app.
@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()
    
    let articlesRepo: ArticlesRepositoryProtocol
    let categoriesRepo: CategoriesRepositoryProtocol
    let favoritesManager: FavoritesManager
    let historyManager: ReadingHistoryManager
    let ratingManager: RatingManager
    let readingProgressTracker: ReadingProgressTracker
    let textSizeManager: TextSizeManager
    let readingTimeTracker: ReadingTimeTracker
    let localizationManager: LocalizationManager // ✅ Добавляем

    init(
        articlesRepo: ArticlesRepositoryProtocol? = nil,
        categoriesRepo: CategoriesRepositoryProtocol? = nil,
        favoritesManager: FavoritesManager? = nil,
        historyManager: ReadingHistoryManager? = nil,
        ratingManager: RatingManager? = nil,
        readingProgressTracker: ReadingProgressTracker? = nil,
        textSizeManager: TextSizeManager? = nil,
        readingTimeTracker: ReadingTimeTracker? = nil,
        localizationManager: LocalizationManager? = nil // ✅ Добавляем параметр
    ) {
        self.articlesRepo = articlesRepo ?? ArticlesRepositoryImpl(dataService: DataService.shared)
        self.categoriesRepo = categoriesRepo ?? DefaultCategoriesRepository.shared
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.historyManager = historyManager ?? ReadingHistoryManager.shared
        self.ratingManager = ratingManager ?? RatingManager.shared
        self.readingProgressTracker = readingProgressTracker ?? ReadingProgressTracker.shared
        self.textSizeManager = textSizeManager ?? TextSizeManager.shared
        self.readingTimeTracker = readingTimeTracker ?? ReadingTimeTracker.shared
        self.localizationManager = localizationManager ?? LocalizationManager.shared // ✅ Инициализируем
    }

    // MARK: - Factory Methods

    /// Creates a HomeViewModel with injected dependencies
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesManager,
            readingHistoryManager: historyManager,
            categoriesRepository: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    /// Creates a SearchViewModel with injected dependencies
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            favoritesManager: favoritesManager,
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    /// Creates a CategoriesViewModel with injected dependencies
    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo,
            favoritesManager: favoritesManager
        )
    }

    /// Creates a FavoritesViewModel with injected dependencies
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesManager,
            articlesRepo: articlesRepo
        )
    }

    /// Creates a SettingsViewModel with injected dependencies
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(historyManager: historyManager)
    }

    /// Creates an ArticleDetailViewModel for a specific article
    func makeArticleDetailViewModel(article: Article, allArticles: [Article]) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            favoritesManager: favoritesManager,
            historyManager: historyManager
        )
    }

    /// Creates an AboutViewModel
    func makeAboutViewModel() -> AboutViewModel {
        AboutViewModel()
    }
}
