import SwiftUI

@MainActor
final class ArticleDetailViewModel: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var contentHeight: CGFloat = 1
    @Published var viewHeight: CGFloat = 1
    @Published var showRelatedArticles = false
    @Published var showTextSizePanel = false
    @Published var rating: Int
    @Published var isFavorite: Bool

    private let article: Article
    let allArticles: [Article]

    let localizationManager: LocalizationManager
    let textSizeManager: TextSizeManager
    let favoritesManager: FavoritesManager
    let ratingManager: RatingManager
    let readingStatsManager: ReadingStatsManaging
    private let articleFormatter: ArticleFormatter

    init(
        article: Article,
        allArticles: [Article],
        localizationManager: LocalizationManager,
        textSizeManager: TextSizeManager,
        favoritesManager: FavoritesManager,
        ratingManager: RatingManager,
        readingStatsManager: ReadingStatsManaging,
        articleFormatter: ArticleFormatter
    ) {
        self.article = article
        self.allArticles = allArticles
        self.localizationManager = localizationManager
        self.textSizeManager = textSizeManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.readingStatsManager = readingStatsManager
        self.articleFormatter = articleFormatter

        self.rating = ratingManager.getRating(for: article.id)
        self.isFavorite = favoritesManager.isFavorite(article.id)
    }

    var currentFont: Font {
        .system(size: 16 * textSizeManager.customScale)
    }

    var progress: CGFloat {
        readingStatsManager.progressForArticle(article.id)
    }

    var relatedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.prefix(3))
    }

    var recommendedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.shuffled().prefix(4))
    }

    func t(_ key: String, lang: String) -> String {
        localizationManager.getTranslation(key: key, language: lang)
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    func setRating(_ newRating: Int) {
        ratingManager.setRating(newRating, for: article.id)
        rating = newRating
    }

    func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let progress = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
        readingStatsManager.updateProgress(for: article.id, value: progress)
    }

    func startReadingSession() {
        readingStatsManager.startSession(articleId: article.id)
    }

    func endReadingSession() {
        readingStatsManager.endSession(articleId: article.id)
    }

    func shareContent(selectedLanguage: String) -> String {
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let readingTimeMinutes = articleFormatter.readingTime(article, for: selectedLanguage)
        let formattedReadingTime = readingStatsManager.formatReadingTime(readingTimeMinutes, language: selectedLanguage)

        return """
        \(title)

        \(content)

        \(t("Время чтения", lang: selectedLanguage)): \(formattedReadingTime)
        \(t("Опубликовано", lang: selectedLanguage)): \(articleFormatter.formattedCreatedDate(article, for: selectedLanguage))
        """
    }
}
