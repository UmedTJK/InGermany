// ./Protocols/RatingManagerProtocol.swift

import Foundation

/// Протокол для управления рейтингами статей.
/// Используется во ViewModel для доступа к RatingManager.
@MainActor
protocol RatingManagerProtocol {
    /// Возвращает рейтинг статьи
    func getRating(for articleId: String) -> Int
    
    /// Устанавливает новый рейтинг для статьи
    func setRating(_ rating: Int, for articleId: String)
    
    /// Очистка данных (например, для тестов)
    func clearForTesting()
}
