
//
//  FavoritesManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
//  FavoritesManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import SwiftUI

class FavoritesManager: ObservableObject {
    @AppStorage("favoriteArticles") private var storedFavorites: Data = Data()
    @Published private(set) var favoriteIDs: Set<String> = [] // Убедитесь что это Set<String>

    init() {
        loadFavorites()
    }

    private func loadFavorites() {
        if let ids = try? JSONDecoder().decode(Set<String>.self, from: storedFavorites) {
            favoriteIDs = ids
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIDs) {
            storedFavorites = data
        }
    }

    func isFavorite(id: String) -> Bool { // Убедитесь что параметр String
        favoriteIDs.contains(id) // Теперь оба String
    }

    func toggleFavorite(id: String) { // Убедитесь что параметр String
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        saveFavorites()
    }

    func favoriteArticles(from articles: [Article]) -> [Article] {
        articles.filter { favoriteIDs.contains($0.id) } // $0.id должен быть String
    }
}
