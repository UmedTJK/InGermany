//
//  ArticleRowViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published var isFavorite: Bool
    @Published var rating: Int
    @Published var imageName: String?

    let article: Article
    
    // ✅ ПРАВИЛЬНО: Через dependency injection
    private let localizationManager: LocalizationManagerProtocol
    private var selectedLanguage: String {
        localizationManager.selectedLanguage
    }

    private let favoritesManager: FavoritesManager
    private let ratingManager: RatingManager
    private let categoriesRepo: CategoriesRepositoryProtocol
    private let readingProgressTracker: ReadingProgressTracker
    private let articleFormatter: ArticleFormatter

    init(
        article: Article,
        localizationManager: LocalizationManagerProtocol,
        favoritesManager: FavoritesManager,
        ratingManager: RatingManager,
        categoriesRepo: CategoriesRepositoryProtocol,
        readingProgressTracker: ReadingProgressTracker,
        articleFormatter: ArticleFormatter
    ) {
        self.article = article
        self.localizationManager = localizationManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.categoriesRepo = categoriesRepo
        self.readingProgressTracker = readingProgressTracker
        self.articleFormatter = articleFormatter
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
        self.imageName = article.image
    }

    /// Упрощённый инициализатор (устаревший — использовать только для превью).
    convenience init(article: Article) {
        self.init(
            article: article,
            localizationManager: LocalizationManager.shared,
            favoritesManager: FavoritesManager.shared,
            ratingManager: RatingManager.shared,
            categoriesRepo: DefaultCategoriesRepository.shared,
            readingProgressTracker: ReadingProgressTracker.shared,
            articleFormatter: ArticleFormatter()
        )
    }

    // MARK: - Favorites
    // ✅ ДОБАВЛЕНО: Метод для переключения избранного
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    // MARK: - Rating
    // ✅ ДОБАВЛЕНО: Метод для установки рейтинга
    func setRating(_ value: Int) {
        ratingManager.setRating(value, for: article.id)
        rating = value
    }

    // MARK: - Metadata
    var title: String {
        article.localizedTitle(for: selectedLanguage)
    }

    var subtitle: String {
        let readingTime = articleFormatter.readingTime(article, for: selectedLanguage)
        return ReadingTimeCalculator.formatReadingTime(readingTime, language: selectedLanguage)
    }

    var metaInfo: String {
        let createdDate = articleFormatter.formattedCreatedDate(article, for: selectedLanguage)
        let updatedDate = articleFormatter.formattedUpdatedDate(article, for: selectedLanguage)
        return [createdDate, updatedDate].joined(separator: " · ")
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
        category?.localizedName(for: selectedLanguage)
    }

    var cardViewRating: Int {
        rating
    }
}
