//
//  RatingManager.swift
//  InGermany
//

import Foundation

/// Менеджер для управления рейтингами статей.
/// Хранит значения рейтингов в `UserDefaults` с префиксом ключей `rating_<id>`.
/// Реализован как `ObservableObject` для реактивного обновления UI.
final class RatingManager: ObservableObject {
    /// Глобально доступный экземпляр менеджера.
    static let shared = RatingManager()
    
    private let keyPrefix = "rating_"
    
    /// Словарь текущих рейтингов статей (ключ — `articleId`, значение — рейтинг).
    @Published private var ratings: [String: Int] = [:]
    
    /// Приватный инициализатор. При создании загружает сохранённые рейтинги из `UserDefaults`.
    private init() {
        loadRatings()
    }

    /// Возвращает рейтинг для указанной статьи.
    /// - Parameter articleId: Уникальный идентификатор статьи.
    /// - Returns: Значение рейтинга (по умолчанию 0, если не найдено).
    func getRating(for articleId: String) -> Int {
        ratings[articleId] ?? 0
    }

    /// Устанавливает рейтинг для указанной статьи и сохраняет его в `UserDefaults`.
    /// - Parameters:
    ///   - rating: Новое значение рейтинга.
    ///   - articleId: Уникальный идентификатор статьи.
    func setRating(_ rating: Int, for articleId: String) {
        ratings[articleId] = rating
        UserDefaults.standard.set(rating, forKey: keyPrefix + articleId)
    }

    /// Загружает все рейтинги из `UserDefaults` в память.
    private func loadRatings() {
        let defaults = UserDefaults.standard
        for (key, value) in defaults.dictionaryRepresentation() {
            if key.starts(with: keyPrefix), let intValue = value as? Int {
                let articleId = String(key.dropFirst(keyPrefix.count))
                ratings[articleId] = intValue
            }
        }
    }
}
