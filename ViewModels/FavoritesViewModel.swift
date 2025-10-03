//
//  FavoritesViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteArticles: [Article] = []
    @Published var allArticles: [Article] = []
    @Published var isLoading: Bool = true
    @Published var dataSource: String = "unknown"

    let favoritesManager: FavoritesManager
    private let articlesRepo: ArticlesRepository

    init(
        favoritesManager: FavoritesManager,
        articlesRepo: ArticlesRepository
    ) {
        self.favoritesManager = favoritesManager
        self.articlesRepo = articlesRepo
    }

    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    // MARK: - Load
    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        let loaded = await articlesRepo.loadArticles()
        let source = await articlesRepo.getLastSource()
        self.allArticles = loaded
        self.favoriteArticles = favoritesManager.favoriteArticles(from: loaded)
        self.dataSource = source
    }

    func toggleFavorite(articleId: String) {
        favoritesManager.toggleFavorite(for: articleId)
        Task { await loadFavorites() }
    }
}
