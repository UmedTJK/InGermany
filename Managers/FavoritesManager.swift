//
//  FavoritesManager.swift
//  InGermany
//

import Foundation
import Combine

/// Singleton-менеджер для управления избранными статьями.
/// Работает как `ObservableObject`, чтобы UI мог подписываться на изменения.
/// Использует `DefaultsStore` для сохранения и загрузки списка избранных.
@MainActor
final class FavoritesManager: ObservableObject {
    /// Глобально доступный экземпляр менеджера.
    static let shared = FavoritesManager()

    /// Текущий набор избранных статей (по их `id`).
    @Published private(set) var favorites: Set<String> = []

    private let key = "favorites"

    /// Инициализация с загрузкой сохранённых данных из `DefaultsStore`.
    private init() {
        if let saved: [String] = DefaultsStore.load(key, as: [String].self) {
            favorites = Set(saved)
        }
    }

    /// Переключает состояние избранного для указанной статьи.
    /// - Parameter articleId: Уникальный идентификатор статьи.
    func toggleFavorite(for articleId: String) {
        if favorites.contains(articleId) {
            favorites.remove(articleId)
        } else {
            favorites.insert(articleId)
        }
        save()
    }

    /// Проверяет, добавлена ли статья в избранное.
    /// - Parameter articleId: Уникальный идентификатор статьи.
    /// - Returns: `true`, если статья в избранном.
    func isFavorite(_ articleId: String) -> Bool {
        favorites.contains(articleId)
    }

    /// Фильтрует массив статей, возвращая только те, что отмечены как избранные.
    /// - Parameter articles: Список статей.
    /// - Returns: Список избранных статей.
    func favoriteArticles(from articles: [Article]) -> [Article] {
        articles.filter { favorites.contains($0.id) }
    }

    /// Проверка избранного для совместимости со старым кодом.
    /// Делегирует вызов методу `isFavorite(_:)`.
    /// - Parameter id: Уникальный идентификатор статьи.
    /// - Returns: `true`, если статья в избранном.
    func isFavorite(id: String) -> Bool {
        isFavorite(id)
    }

    /// Сохраняет текущий список избранных в `DefaultsStore`.
    private func save() {
        DefaultsStore.save(Array(favorites), for: key)
    }
    
    // В FavoritesManager.swift исправьте метод clearForTesting():
    func clearForTesting() {
        // Очистка favorites для тестов
        favorites.removeAll()
        save()
    }
}
