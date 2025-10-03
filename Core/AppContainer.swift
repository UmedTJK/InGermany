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
}
