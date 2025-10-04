//
//  ArticleRowViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//

import SwiftUI

/// ViewModel для строки статьи (`ArticleRow`).
/// Отвечает за управление состоянием избранного, рейтинга и отображения метаданных.
/// Использует `FavoritesManager` и `RatingManager`.
@MainActor
class ArticleRowViewModel: ObservableObject {
    /// Флаг, указывающий, добавлена ли статья в избранное.
    @Published var isFavorite: Bool
    
    /// Текущий рейтинг статьи (например, от 0 до 5).
    @Published var rating: Int
    
    /// Имя изображения, связанного со статьёй.
    @Published var imageName: String?
    
    /// Статья, для которой создаётся ViewModel.
    let article: Article
    
    /// Менеджер для управления избранными статьями
    private let favoritesManager: FavoritesManager
    /// Менеджер для хранения и получения рейтингов статей
    private let ratingManager: RatingManager
    
    /// Основной инициализатор ViewModel.
    /// - Parameters:
    ///   - article: Модель статьи.
    ///   - favoritesManager: Менеджер для работы с избранным.
    ///   - ratingManager: Менеджер для работы с рейтингами.
    init(article: Article,
         favoritesManager: FavoritesManager,
         ratingManager: RatingManager) {
        self.article = article
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
        self.imageName = article.image
    }
    
    /// Упрощённый инициализатор, использующий глобальные `shared` менеджеры.
    /// - Parameter article: Модель статьи.
    convenience init(article: Article) {
        self.init(article: article,
                  favoritesManager: FavoritesManager.shared,
                  ratingManager: RatingManager.shared)
    }
    
    // MARK: - Favorites
    
    /// Переключает состояние избранного для статьи.
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }
    
    // MARK: - Rating
    
    /// Устанавливает рейтинг для статьи.
    /// - Parameter value: Значение рейтинга (например, от 0 до 5).
    func setRating(_ value: Int) {
        ratingManager.setRating(value, for: article.id)
        rating = value
    }
    
    // MARK: - Metadata
    
    /// Локализованный заголовок статьи.
    var title: String {
        article.localizedTitle(for: "ru") // можно подставить язык из настроек
    }
    
    /// Краткая информация, например время чтения.
    var subtitle: String {
        article.formattedReadingTime(for: "ru")
    }
    
    /// Метаданные статьи: дата создания и дата обновления.
    var metaInfo: String {
        [
            article.formattedCreatedDate(for: "ru"),
            article.formattedUpdatedDate(for: "ru")
        ]
        .joined(separator: " · ")
    }
}
