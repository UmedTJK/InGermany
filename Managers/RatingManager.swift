//
//  RatingManager.swift
//  InGermany
//

import Foundation
import Combine

/// Менеджер для хранения и управления рейтингами статей.
@MainActor
final class RatingManager: ObservableObject {
    static let shared = RatingManager()

    @Published private(set) var ratings: [String: Int] = [:]

    private let key = "ratings"

    private init() {
        if let saved: [String: Int] = DefaultsStorage.load(key, as: [String: Int].self) {
            ratings = saved
        }
    }

    func setRating(_ rating: Int, for articleId: String) {
        ratings[articleId] = rating
        save()
    }

    func getRating(for articleId: String) -> Int {
        ratings[articleId] ?? 0
    }

    private func save() {
        DefaultsStorage.save(ratings, for: key)
    }
}
