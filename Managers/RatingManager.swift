//
//  RatingManager.swift
//  InGermany
//
//  Created by SUM TJK on 16.09.25.
//
import Foundation

class RatingManager: ObservableObject {
    static let shared = RatingManager()
    
    private let keyPrefix = "rating_"
    
    // Храним оценки в оперативной памяти (для быстрого отображения)
    @Published private var ratings: [String: Int] = [:]
    
    private init() {
        loadRatings()
    }

    func rating(for articleId: String) -> Int {
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
