//
//  FavoritesManager.swift
//  InGermany
//

import SwiftUI

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()  // ✅ Добавлен синглтон

    @AppStorage("favoriteArticles") private var storedFavorites: Data = Data()
    @Published private(set) var favoriteIDs: Set<String> = [] // Теперь String

    init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let ids = try? JSONDecoder().decode(Set<String>.self, from: storedFavorites) {
            favoriteIDs = ids
        }
    }

    public func saveFavorites() {  // ✅ Сделан публичным
        if let data = try? JSONEncoder().encode(favoriteIDs) {
            storedFavorites = data
        }
    }

    func isFavorite(id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        saveFavorites()
    }

    func favoriteArticles(from articles: [Article]) -> [Article] {
        articles.filter { favoriteIDs.contains($0.id) }
    }

    // Методы для Article
    func isFavorite(article: Article) -> Bool {
        favoriteIDs.contains(article.id)
    }

    func toggleFavorite(article: Article) {
        toggleFavorite(id: article.id)
    }
}
