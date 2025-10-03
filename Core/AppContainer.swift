//
//  AppContainer.swift
//  InGermany
//

import Foundation

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    // Repositories
    let articlesRepo: ArticlesRepository
    let categoriesRepo: CategoriesRepository

    // Managers
    let favoritesManager: FavoritesManager
    let historyManager: ReadingHistoryManager

    private init() {
        self.articlesRepo = ArticlesRepositoryImpl()
        self.categoriesRepo = CategoriesRepository.shared
        self.favoritesManager = FavoritesManager.shared
        self.historyManager = ReadingHistoryManager.shared
    }

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
            favoritesManager: favoritesManager,
            categoriesRepo: categoriesRepo,
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
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesManager,
            articlesRepo: articlesRepo
        )
    }
    


}
