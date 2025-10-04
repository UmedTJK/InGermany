//
//  AppContainer.swift
//  InGermany
//

import Foundation

/// The main dependency injection container for the app.
/// Holds singletons and factories for repositories, managers, and ViewModels.
@MainActor
final class AppContainer {
    static let shared = AppContainer()

    /// Repository managing all article data access and operations.
    let articlesRepo: ArticlesRepository
    /// Repository managing all category data access and operations.
    let categoriesRepo: CategoriesRepository

    /// Manager for handling user's favorite articles.
    let favoritesManager: FavoritesManager
    /// Manager for handling user's reading history.
    let historyManager: ReadingHistoryManager

    private init() {
        self.articlesRepo = ArticlesRepositoryImpl()
        self.categoriesRepo = DefaultCategoriesRepository.shared
        self.favoritesManager = FavoritesManager.shared
        self.historyManager = ReadingHistoryManager.shared
    }

    /// Creates a HomeViewModel with injected favorites manager, reading history manager, categories repository, and articles repository.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesManager,
            readingHistoryManager: historyManager,
            categoriesRepository: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }
    
    /// Creates a SearchViewModel with injected favorites manager, categories repository, and articles repository.
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            favoritesManager: favoritesManager,
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }
    
    /// Creates a CategoriesViewModel with injected categories repository and articles repository.
    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }
    
    /// Creates a SettingsViewModel with the reading history manager injected.
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(historyManager: historyManager)
    }
    
    /// Creates an ArticleDetailViewModel for a specific article and the list of all articles, with favorites and history managers injected.
    func makeArticleDetailViewModel(article: Article, allArticles: [Article]) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            favoritesManager: favoritesManager,
            historyManager: historyManager
        )
    }
    
    /// Creates an AboutViewModel.
    func makeAboutViewModel() -> AboutViewModel {
        AboutViewModel()
    }
    
    /// Creates a FavoritesViewModel with favorites manager and articles repository injected.
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesManager,
            articlesRepo: articlesRepo
        )
    }
    


}
