//
//  RatingManager.swift
//  InGermany
//

import Foundation
import Combine

@MainActor  // ✅ Добавляем MainActor для гарантии работы на главном потоке
final class RatingManager: ObservableObject {
    
    static let shared = RatingManager()
    
    @Published private var ratings: [String: Int] = [:]
    
    private let userDefaultsKey = "articleRatings"
    private let userDefaults: UserDefaults
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadRatings()
    }
    
    func getRating(for articleId: String) -> Int {
        return ratings[articleId] ?? 0
    }
    
    func setRating(_ rating: Int, for articleId: String) {
        // ✅ Гарантируем выполнение на главном потоке благодаря @MainActor
        ratings[articleId] = rating
        saveRatings()
    }
    
    func clearForTesting() {
        ratings.removeAll()
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
    
    private func loadRatings() {
        if let data = userDefaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            ratings = decoded
        }
    }
    
    private func saveRatings() {
        if let encoded = try? JSONEncoder().encode(ratings) {
            userDefaults.set(encoded, forKey: userDefaultsKey)
        }
    }
}
