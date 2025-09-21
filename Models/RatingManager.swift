//
//  RatingManager.swift
//  InGermany
//

import Foundation

@MainActor
final class RatingManager: ObservableObject {
    @Published private(set) var ratings: [String: Int] = [:]
    
    func setRating(for articleId: String, rating: Int) {
        ratings[articleId] = rating
    }
    
    func rating(for articleId: String) -> Int? {
        ratings[articleId]
    }
}

// MARK: - Sample Data для Preview
extension RatingManager {
    static let example: RatingManager = {
        let manager = RatingManager()
        manager.setRating(for: "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa", rating: 5)
        manager.setRating(for: "22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb", rating: 3)
        return manager
    }()
}
