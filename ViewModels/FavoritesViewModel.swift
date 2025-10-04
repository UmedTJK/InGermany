//
//  FavoritesViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages favorite articles and their loading state.
@MainActor
class FavoritesViewModel: ObservableObject {
    /// All loaded articles.
    @Published var allArticles: [Article] = []
    /// The subset of articles marked as favorite.
    @Published var favoriteArticles: [Article] = []
    /// Indicates whether the favorites data is currently being loaded.
    @Published var isLoading: Bool = true
    /// Shows the source of the last data load (e.g., memory, local, or network).
    @Published var dataSource: String = "unknown"   // ✅ вот это свойство нужно

    /// Manager for handling favorite articles.
    private let favoritesManager: FavoritesManager
    /// Repository for loading article data.
    private let articlesRepo: ArticlesRepository

    /// Injects dependencies for favorites and articles repository.
    init(favoritesManager: FavoritesManager, articlesRepo: ArticlesRepository) {
        self.favoritesManager = favoritesManager
        self.articlesRepo = articlesRepo
    }

    /// Loads all articles and filters favorites, updating state accordingly.
    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        let loaded = await articlesRepo.loadArticles()
        allArticles = loaded
        favoriteArticles = favoritesManager.favoriteArticles(from: loaded)
        self.dataSource = await articlesRepo.getLastSource()
    }

    /// Toggles the favorite status of the given article and updates the list of favorite articles.
    func toggleFavorite(for articleId: String) {
        favoritesManager.toggleFavorite(for: articleId)
        favoriteArticles = favoritesManager.favoriteArticles(from: allArticles)
    }
}
