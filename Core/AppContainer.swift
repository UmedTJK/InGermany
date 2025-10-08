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

    // MARK: - Managers (конкретные классы для SwiftUI EnvironmentObject)
    let favoritesManager: FavoritesManager
    let historyManager: ReadingHistoryManager
    let ratingManager: RatingManager
    let readingProgressTracker: ReadingProgressTracker
    let textSizeManager: TextSizeManager
    let readingTimeTracker: ReadingTimeTracker
    let localizationManager: LocalizationManager

    // MARK: - Services
    let dataService: DataService

    init(
        articlesRepo: ArticlesRepositoryProtocol? = nil,
        categoriesRepo: CategoriesRepositoryProtocol? = nil,
        favoritesManager: FavoritesManager? = nil,
        historyManager: ReadingHistoryManager? = nil,
        ratingManager: RatingManager? = nil,
        readingProgressTracker: ReadingProgressTracker? = nil,
        textSizeManager: TextSizeManager? = nil,
        readingTimeTracker: ReadingTimeTracker? = nil,
        localizationManager: LocalizationManager? = nil,
        dataService: DataService? = nil
    ) {
        // ✅ Services & Repos
        let dataServiceInstance = dataService ?? DataService.shared
        self.dataService = dataServiceInstance

        self.articlesRepo = articlesRepo ?? ArticlesRepositoryImpl(dataService: dataServiceInstance)
        self.categoriesRepo = categoriesRepo ?? DefaultCategoriesRepository.shared

        // ✅ Managers (конкретные классы)
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.historyManager = historyManager ?? ReadingHistoryManager.shared
        self.ratingManager = ratingManager ?? RatingManager.shared
        self.readingProgressTracker = readingProgressTracker ?? ReadingProgressTracker.shared
        self.textSizeManager = textSizeManager ?? TextSizeManager.shared
        self.readingTimeTracker = readingTimeTracker ?? ReadingTimeTracker.shared
        self.localizationManager = localizationManager ?? LocalizationManager.shared
    }

    // MARK: - ViewModel Factory Methods

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesManager,
            readingHistoryManager: historyManager,
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
            historyManager: historyManager,
            localizationManager: localizationManager // как протокол передастся сам
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
            readingProgressTracker: readingProgressTracker,
            readingTimeTracker: readingTimeTracker,
            historyManager: historyManager
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
            readingProgressTracker: readingProgressTracker
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
            .environmentObject(readingProgressTracker)
            .environmentObject(readingTimeTracker)
            .environmentObject(ratingManager)
    }

    // MARK: - Clear All Data (for testing)

    func clearAllData() {
        favoritesManager.clearForTesting()
        ratingManager.clearForTesting()
        historyManager.clearForTesting()
    }
    
}

extension AppContainer {
    static func previewMock() -> AppContainer {
        AppContainer()
    }
}
