//
//  FavoritesViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var allArticles: [Article] = []
    @Published var favoriteArticles: [Article] = []
    @Published var isLoading: Bool = true
    @Published var dataSource: String = "unknown"   // ✅ вот это свойство нужно

    private let favoritesManager: FavoritesManager
    private let articlesRepo: ArticlesRepository

    init(favoritesManager: FavoritesManager, articlesRepo: ArticlesRepository) {
        self.favoritesManager = favoritesManager
        self.articlesRepo = articlesRepo
    }

    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        let loaded = await articlesRepo.loadArticles()
        allArticles = loaded
        favoriteArticles = favoritesManager.favoriteArticles(from: loaded)
        self.dataSource = await articlesRepo.getLastSource()
    }

    func toggleFavorite(for articleId: String) {
        favoritesManager.toggleFavorite(for: articleId)
        favoriteArticles = favoritesManager.favoriteArticles(from: allArticles)
    }
}
