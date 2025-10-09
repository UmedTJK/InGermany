import SwiftUI

@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published var isFavorite: Bool
    @Published var rating: Int
    @Published var imageName: String?

    let article: Article

    private let localizationManager: LocalizationManagerProtocol
    private var selectedLanguage: String {
        localizationManager.selectedLanguage
    }

    private let favoritesManager: FavoritesManager
    private let ratingManager: RatingManager
    private let categoriesRepo: CategoriesRepositoryProtocol
    private let readingStatsManager: ReadingStatsManaging
    private let articleFormatter: ArticleFormatter

    init(
        article: Article,
        localizationManager: LocalizationManagerProtocol,
        favoritesManager: FavoritesManager,
        ratingManager: RatingManager,
        categoriesRepo: CategoriesRepositoryProtocol,
        readingStatsManager: ReadingStatsManaging,
        articleFormatter: ArticleFormatter
    ) {
        self.article = article
        self.localizationManager = localizationManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.categoriesRepo = categoriesRepo
        self.readingStatsManager = readingStatsManager
        self.articleFormatter = articleFormatter
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
        self.imageName = article.image
    }

    convenience init(article: Article) {
        self.init(
            article: article,
            localizationManager: LocalizationManager.shared,
            favoritesManager: FavoritesManager.shared,
            ratingManager: RatingManager.shared,
            categoriesRepo: DefaultCategoriesRepository.shared,
            readingStatsManager: ReadingStatsManager.shared,
            articleFormatter: ArticleFormatter()
        )
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    func setRating(_ value: Int) {
        ratingManager.setRating(value, for: article.id)
        rating = value
    }

    var title: String {
        article.localizedTitle(for: selectedLanguage)
    }

    var subtitle: String {
        let readingTime = articleFormatter.readingTime(article, for: selectedLanguage)
        return readingStatsManager.formatReadingTime(readingTime, language: selectedLanguage)
    }

    var metaInfo: String {
        let createdDate = articleFormatter.formattedCreatedDate(article, for: selectedLanguage)
        let updatedDate = articleFormatter.formattedUpdatedDate(article, for: selectedLanguage)
        return [createdDate, updatedDate].joined(separator: " · ")
    }

    var category: Category? {
        categoriesRepo.category(by: article.categoryId)
    }

    var progress: Double {
        Double(readingStatsManager.progressForArticle(article.id))
    }
}
