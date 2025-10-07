//
//  ArticleRowViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//

import SwiftUI

/// ViewModel для строки статьи (`ArticleRow`).
/// Отвечает за управление состоянием избранного, рейтинга, метаданных и прогресса чтения.
/// Использует `FavoritesManager`, `RatingManager`, `ReadingProgressTracker` и `CategoriesRepositoryProtocol`.
@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published var isFavorite: Bool
    @Published var rating: Int
    @Published var imageName: String?

    let article: Article

    private let favoritesManager: FavoritesManager
    private let ratingManager: RatingManager
    private let categoriesRepo: CategoriesRepositoryProtocol
    private let readingProgressTracker: ReadingProgressTracker

    init(
        article: Article,
        favoritesManager: FavoritesManager,
        ratingManager: RatingManager,
        categoriesRepo: CategoriesRepositoryProtocol,
        readingProgressTracker: ReadingProgressTracker
    ) {
        self.article = article
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.categoriesRepo = categoriesRepo
        self.readingProgressTracker = readingProgressTracker
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
        self.imageName = article.image
    }

    /// Упрощённый инициализатор (устаревший — использовать только для превью).
    convenience init(article: Article) {
        self.init(
            article: article,
            favoritesManager: FavoritesManager.shared,
            ratingManager: RatingManager.shared,
            categoriesRepo: DefaultCategoriesRepository.shared,
            readingProgressTracker: ReadingProgressTracker.shared
        )
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
        article.localizedTitle(for: "ru")
    }

    var subtitle: String {
        article.formattedReadingTime(for: "ru")
    }

    var metaInfo: String {
        [
            article.formattedCreatedDate(for: "ru"),
            article.formattedUpdatedDate(for: "ru")
        ].joined(separator: " · ")
    }

    var category: Category? {
        categoriesRepo.category(by: article.categoryId)
    }

    /// Текущий прогресс чтения статьи (0.0 ... 1.0)
    var progress: Double {
        Double(readingProgressTracker.progressForArticle(article.id))
    }

}

// MARK: - Расширения для ArticleCard / CompactCard
extension ArticleRowViewModel {
    var compactCardImageName: String {
        article.imageName
    }

    var compactCardCategory: String? {
        category?.localizedName(for: "ru")
    }

    var cardViewRating: Int {
        rating
    }
}
