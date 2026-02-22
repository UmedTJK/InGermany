//
//  FavoritesManager.swift
//  InGermany
//

import Foundation
import Combine

/// Менеджер для управления избранными статьями.
/// Работает как `ObservableObject`, чтобы UI мог подписываться на изменения.
/// Использует `DefaultsStore` для сохранения и загрузки списка избранных.
@MainActor
final class FavoritesManager: ObservableObject {
    /// Текущий набор избранных статей (по их `id`).
    @Published private(set) var favorites: Set<String> = []

    private let key = "favorites"

    /// Инициализация без I/O. Загрузка выполняется явно через `bootstrap()`.
    init() {}

    // MARK: - Bootstrap
    func bootstrap() async {
        await loadFavoritesFromStorage()
    }

    private func loadFavoritesFromStorage() async {
        do {
            let saved: [String] = try await DefaultsStore.loadAsync(key, as: [String].self) ?? []
            favorites = Set(saved)
        } catch {
            print("⚠️ [FavoritesManager] Failed to load favorites: \(error)")
            favorites = []
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

    /// Сохраняет текущий список избранных в `DefaultsStore` (async, encode off-main).
    private func save() {
        let snapshot = Array(favorites)
        Task(priority: .utility) {
            do {
                try await DefaultsStore.saveAsync(snapshot, for: key)
            } catch {
                print("⚠️ [FavoritesManager] Failed to save favorites: \(error)")
            }
        }
    }
    
    // В FavoritesManager.swift исправьте метод clearForTesting():
    func clearForTesting() {
        // Очистка favorites для тестов
        favorites.removeAll()
        save()
    }
}
