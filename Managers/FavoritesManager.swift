//
//  FavoritesManager.swift
//  InGermany
//

import Foundation
import Combine

/// Унифицированный менеджер избранных статей.
/// Использует DefaultsStorage для сохранения и загрузки.
@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published private(set) var favorites: Set<String> = []

    private let key = "favorites"

    private init() {
        // Загружаем сохранённые данные
        if let saved: [String] = DefaultsStorage.load(key, as: [String].self) {
            favorites = Set(saved)
        }
    }

    func toggleFavorite(for articleId: String) {
        if favorites.contains(articleId) {
            favorites.remove(articleId)
        } else {
            favorites.insert(articleId)
        }
        save()
    }

    func isFavorite(_ articleId: String) -> Bool {
        favorites.contains(articleId)
    }

    private func save() {
        DefaultsStorage.save(Array(favorites), for: key)
    }
}
