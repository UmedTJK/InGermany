//
//  AppContainer.swift
//  InGermany
//

import SwiftUI
import Foundation

/// The main dependency injection container for the app.
@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()

    // MARK: - Core Repositories
    let articlesRepo: ArticlesRepositoryProtocol
    let categoriesRepo: CategoriesRepositoryProtocol

    // MARK: - Managers
    let favoritesManager: FavoritesManager
    let ratingManager: RatingManager
    let textSizeManager: TextSizeManager
    let localizationManager: LocalizationManager
    let readingStatsManager: ReadingStatsManaging

    private let dateFormattingService = DateFormattingService.shared
    private let textAnalysisService = TextAnalysisService.shared

    // MARK: - Services
    let dataService: DataService
    private let articleFormatter = ArticleFormatter()

    func makeArticleFormatter() -> ArticleFormatter {
        return articleFormatter
    }

    init(
        articlesRepo: ArticlesRepositoryProtocol? = nil,
        categoriesRepo: CategoriesRepositoryProtocol? = nil,
        favoritesManager: FavoritesManager? = nil,
        ratingManager: RatingManager? = nil,
        textSizeManager: TextSizeManager? = nil,
        localizationManager: LocalizationManager? = nil,
        dataService: DataService? = nil,
        readingStatsManager: ReadingStatsManaging? = nil
    ) {
        // ✅ Services & Repos
        let dataServiceInstance = dataService ?? DataService.shared
        self.dataService = dataServiceInstance

        self.articlesRepo = articlesRepo ?? ArticlesRepositoryImpl(dataService: dataServiceInstance)
        self.categoriesRepo = categoriesRepo ?? DefaultCategoriesRepository.shared

        // ✅ Managers
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.ratingManager = ratingManager ?? RatingManager.shared
        self.textSizeManager = textSizeManager ?? TextSizeManager.shared
        self.localizationManager = localizationManager ?? LocalizationManager.shared
        self.readingStatsManager = readingStatsManager ?? ReadingStatsManager.shared
    }

    // MARK: - ViewModel Factory Methods

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesManager,
            readingStatsManager: readingStatsManager,
            categoriesRepository: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            favoritesManager: favoritesManager,
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }

    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo,
            favoritesManager: favoritesManager
        )
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesManager,
            articlesRepo: articlesRepo
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            readingStatsManager: readingStatsManager,
            localizationManager: localizationManager
        )
    }

    func makeArticleDetailViewModel(article: Article, allArticles: [Article]) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            localizationManager: localizationManager,
            textSizeManager: textSizeManager,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager,
            readingStatsManager: readingStatsManager,
            articleFormatter: articleFormatter
        )
    }

    func makeAboutViewModel() -> AboutViewModel {
        AboutViewModel()
    }

    func makeArticleRowViewModel(article: Article) -> ArticleRowViewModel {
        ArticleRowViewModel(
            article: article,
            localizationManager: localizationManager,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager,
            categoriesRepo: categoriesRepo,
            readingStatsManager: readingStatsManager,
            articleFormatter: articleFormatter
        )
    }

    func makeArticleCompactCardViewModel(article: Article) -> ArticleRowViewModel {
        makeArticleRowViewModel(article: article)
    }

    func makeArticleCardViewModel(article: Article) -> ArticleRowViewModel {
        makeArticleRowViewModel(article: article)
    }

    func makeLocationsViewModel() -> LocationsViewModel {
        LocationsViewModel(dataService: dataService)
    }

    func makePDFViewerViewModel() -> PDFViewerViewModel {
        PDFViewerViewModel(localizationManager: localizationManager)
    }

    // MARK: - Global Environment Injection

    func provideEnvironmentObjects() -> some View {
        EmptyView()
            .environmentObject(self)
            .environmentObject(favoritesManager)
            .environmentObject(textSizeManager)
            .environmentObject(localizationManager)
            .environmentObject(ratingManager)
            .environmentObject(readingStatsManager as! ReadingStatsManager) // ✅ кастуем к ObservableObject
    }


    // MARK: - Clear All Data (for testing)

    func clearAllData() {
        favoritesManager.clearForTesting()
        ratingManager.clearForTesting()
        readingStatsManager.clearHistory()
    }
}

extension AppContainer {
    static func previewMock() -> AppContainer {
        AppContainer()
    }
}
