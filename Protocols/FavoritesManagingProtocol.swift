// ./Protocols/FavoritesManagingProtocol.swift

import Foundation

/// Протокол для работы с избранными статьями.
/// Используется во ViewModel для доступа к FavoritesManager.
@MainActor
protocol FavoritesManagingProtocol {
    /// Проверяет, находится ли статья в избранном
    func isFavorite(_ articleId: String) -> Bool
    
    /// Переключает состояние избранного для статьи
    func toggleFavorite(for articleId: String)
}
