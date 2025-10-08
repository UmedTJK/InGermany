//
//  ArticleDetailViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
final class ArticleDetailViewModel: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    @Published var contentHeight: CGFloat = 1
    @Published var viewHeight: CGFloat = 1
    @Published var showRelatedArticles = false
    @Published var showTextSizePanel = false

    private let article: Article
    private let allArticles: [Article]

    let localizationManager: LocalizationManager
    let textSizeManager: TextSizeManager
    let favoritesManager: FavoritesManager
    let ratingManager: RatingManager
    let readingProgressTracker: ReadingProgressTracker
    let readingTimeTracker: ReadingTimeTracker
    let historyManager: ReadingHistoryManager
    private let articleFormatter: ArticleFormatter

    init(article: Article,
         allArticles: [Article],
         localizationManager: LocalizationManager,
         textSizeManager: TextSizeManager,
         favoritesManager: FavoritesManager,
         ratingManager: RatingManager,
         readingProgressTracker: ReadingProgressTracker,
         readingTimeTracker: ReadingTimeTracker,
         historyManager: ReadingHistoryManager,
         articleFormatter: ArticleFormatter) {
        self.article = article
        self.allArticles = allArticles
        self.localizationManager = localizationManager
        self.textSizeManager = textSizeManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.readingProgressTracker = readingProgressTracker
        self.readingTimeTracker = readingTimeTracker
        self.historyManager = historyManager
        self.articleFormatter = articleFormatter
    }

    // MARK: - API for View

    var currentFont: Font {
        .system(size: 16 * textSizeManager.customScale)
    }

    var progress: CGFloat {
        readingProgressTracker.progressForArticle(article.id)
    }

    var relatedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.prefix(3))
    }

    func t(_ key: String, lang: String) -> String {
        localizationManager.getTranslation(key: key, language: lang)
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
    }

    func isFavorite() -> Bool {
        favoritesManager.isFavorite(article.id)
    }

    func getRating() -> Int {
        ratingManager.getRating(for: article.id)
    }

    func setRating(_ rating: Int) {
        ratingManager.setRating(rating, for: article.id)
    }

    func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let progress = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
        readingProgressTracker.updateProgress(for: article.id, value: progress)
    }

    func startReadingSession() {
        readingTimeTracker.startSession(articleId: article.id)
    }

    func endReadingSession() {
        readingTimeTracker.endSession(articleId: article.id)
        historyManager.addReadingEntry(articleId: article.id, readingTime: 60)
    }

    func shareContent(selectedLanguage: String) -> String {
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let readingTime = articleFormatter.readingTime(article, for: selectedLanguage)
        let formattedReadingTime = ReadingTimeCalculator.formatReadingTime(readingTime, language: selectedLanguage)
        
        return """
        \(title)

        \(content)

        \(t("Время чтения", lang: selectedLanguage)): \(formattedReadingTime)
        \(t("Опубликовано", lang: selectedLanguage)): \(articleFormatter.formattedCreatedDate(article, for: selectedLanguage))
        """
    }
}
