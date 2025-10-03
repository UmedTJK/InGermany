//
//  RatingManager.swift
//  InGermany
//
import Foundation

final class RatingManager: ObservableObject {
    static let shared = RatingManager()
    
    private let keyPrefix = "rating_"
    
    @Published private var ratings: [String: Int] = [:]
    
    private init() {
        loadRatings()
    }

    func getRating(for articleId: String) -> Int {
        ratings[articleId] ?? 0
    }

    func setRating(_ rating: Int, for articleId: String) {
        ratings[articleId] = rating
        UserDefaults.standard.set(rating, forKey: keyPrefix + articleId)
    }

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
