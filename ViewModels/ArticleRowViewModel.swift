//
//  ArticleRowViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
//
//  ArticleRowViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//

import SwiftUI

@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published var isFavorite: Bool
    @Published var rating: Int
    
    let article: Article
    
    private let favoritesManager: FavoritesManager
    private let ratingManager: RatingManager
    
    init(article: Article,
         favoritesManager: FavoritesManager,
         ratingManager: RatingManager) {
        self.article = article
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
    }
    
    convenience init(article: Article) {
        self.init(article: article,
                  favoritesManager: FavoritesManager.shared,
                  ratingManager: RatingManager.shared)
    }
    
    // MARK: - Favorites
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }
    
    // MARK: - Rating
    func setRating(_ value: Int) {
        ratingManager.setRating(value, for: article.id)
        rating = value
    }
    
    // MARK: - Metadata
    var title: String {
        article.localizedTitle(for: "ru") // можно подставить язык из настроек
    }
    
    var subtitle: String {
        // например, берём язык интерфейса по умолчанию
        article.formattedReadingTime(for: "ru")
    }
    
    var metaInfo: String {
        [
            article.formattedCreatedDate(for: "ru"),
            article.formattedUpdatedDate(for: "ru")
        ]
        .joined(separator: " · ")
    }
}
