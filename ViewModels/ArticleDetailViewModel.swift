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
    @Published var rating: Int
    @Published var isFavorite: Bool

    // Оставляем открытым для чтения во View
    let article: Article
    let allArticles: [Article]

    let localizationManager: LocalizationManager
    let textSizeManager: TextSizeManager
    let favoritesManager: FavoritesManager
    let ratingManager: RatingManager
    let readingStatsManager: ReadingStatsManaging
    let articleFormatter: ArticleFormatter

    // Репозиторий категорий — для разрешения categoryId → Category
    private let categoriesRepository: CategoriesRepositoryProtocol

    // Сервис шаринга
    private let shareService: ShareServiceProtocol

    init(
        article: Article,
        allArticles: [Article],
        localizationManager: LocalizationManager,
        textSizeManager: TextSizeManager,
        favoritesManager: FavoritesManager,
        ratingManager: RatingManager,
        readingStatsManager: ReadingStatsManaging,
        articleFormatter: ArticleFormatter,
        categoriesRepository: CategoriesRepositoryProtocol,
        shareService: ShareServiceProtocol
    ) {
        self.article = article
        self.allArticles = allArticles
        self.localizationManager = localizationManager
        self.textSizeManager = textSizeManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.readingStatsManager = readingStatsManager
        self.articleFormatter = articleFormatter
        self.categoriesRepository = categoriesRepository
        self.shareService = shareService

        self.rating = ratingManager.getRating(for: article.id)
        self.isFavorite = favoritesManager.isFavorite(article.id)
    }

    // MARK: - Progress

    var progress: CGFloat {
        readingStatsManager.progressForArticle(article.id)
    }

    // MARK: - Related

    /// Возвращает связанные статьи (без текущей)
    func relatedArticles(limit: Int) -> [Article] {
        Array(
            allArticles
                .filter { $0.categoryId == article.categoryId && $0.id != article.id }
                .prefix(limit)
        )
    }

    /// Случайные рекомендации
    var recommendedArticles: [Article] {
        Array(
            allArticles
                .filter { $0.categoryId == article.categoryId && $0.id != article.id }
                .shuffled()
                .prefix(4)
        )
    }

    // MARK: - Localization shortcut

    func t(_ key: String, lang: String) -> String {
        localizationManager.getTranslation(key: key, language: lang)
    }

    // MARK: - Favorites & Rating

    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    func setRating(_ newRating: Int) {
        ratingManager.setRating(newRating, for: article.id)
        rating = newRating
    }

    // MARK: - Reading progress

    func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let denom = max(contentHeight - viewHeight, 1)
        let progressVal = max(0, min(scrollOffset / denom, 1))
        readingStatsManager.updateProgress(for: article.id, value: progressVal)
    }

    func startReadingSession() {
        readingStatsManager.startSession(articleId: article.id)
    }

    func endReadingSession() {
        readingStatsManager.endSession(articleId: article.id)
    }

    // MARK: - Share

    func shareContent(selectedLanguage: String) -> String {
        shareService.generatePlainText(article: article, selectedLanguage: selectedLanguage)
    }

    func showShareSheet(selectedLanguage: String) {
        shareService.showShareSheet(article: article, selectedLanguage: selectedLanguage)
    }

    // MARK: - Category (с фолбэком)

    /// Локализованное имя категории для заданного языка или «Без категории», если id не найден.
    func categoryName(for language: String) -> String {
        if let category = categoriesRepository.category(by: article.categoryId) {
            return category.localizedName(for: language)
        } else {
            return localizationManager.getTranslation(key: "category_none", language: language)
        }
    }

    // MARK: - Child VM

    /// Создаёт дочернюю VM для перехода по NavigationLink
    func createChildViewModel(for article: Article) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            localizationManager: localizationManager,
            textSizeManager: textSizeManager,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager,
            readingStatsManager: readingStatsManager,
            articleFormatter: articleFormatter,
            categoriesRepository: categoriesRepository,
            shareService: shareService
        )
    }

    // MARK: - Lifecycle

    func onAppear() {
        startReadingSession()
    }
}
