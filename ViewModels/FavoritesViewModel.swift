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
    @Published var dataSource: String = "unknown"

    private let favoritesManager: any FavoritesManagingProtocol
    private let articlesRepo: ArticlesRepositoryProtocol

    init(favoritesManager: any FavoritesManagingProtocol, articlesRepo: ArticlesRepositoryProtocol) {
        self.favoritesManager = favoritesManager
        self.articlesRepo = articlesRepo
    }

    func loadFavorites() async {
        isLoading = true
        defer { isLoading = false }
        let loaded = await articlesRepo.loadArticles()
        allArticles = loaded
        favoriteArticles = loaded.filter { favoritesManager.isFavorite($0.id) }
        dataSource = await articlesRepo.getLastSource()
    }

    func toggleFavorite(for articleId: String) {
        favoritesManager.toggleFavorite(for: articleId)
        favoriteArticles = allArticles.filter { favoritesManager.isFavorite($0.id) }
    }
}
