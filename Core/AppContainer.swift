//
//  AppContainer.swift
//  InGermany
//

import SwiftUI
import Foundation

/// The main dependency injection container for the app.
@MainActor
final class AppContainer: ObservableObject {
    // MARK: - Core Repositories
    let articlesRepo: ArticlesRepositoryProtocol
    let categoriesRepo: CategoriesRepositoryProtocol
    
    // MARK: - Managers
    private let favoritesManagerConcrete: FavoritesManager
    let ratingManager: RatingManager
    let textSizeManager: TextSizeManager
    let localizationManager: LocalizationManager
    let settingsManager = SettingsManager()

    
    /// Конкретный экземпляр для SwiftUI
    let readingStatsManager: ReadingStatsManager
    /// Доступ через протокол (для ViewModel)
    var readingStatsService: ReadingStatsManagingProtocol { readingStatsManager }
    /// Доступ к избранному через протокол (для ViewModel)
    var favoritesService: any FavoritesManagingProtocol { favoritesManagerConcrete }
    /// Concrete instance for SwiftUI EnvironmentObject injection
    var favoritesManagerForUI: FavoritesManager { favoritesManagerConcrete }

    
    private let dateFormattingService = DateFormattingService()
    private let textAnalysisService = TextAnalysisService()
    
    // MARK: - Services
    let dataService: DataServiceProtocol
    private let articleFormatter: ArticleFormatter
    
    // ✅ ShareService
    private let shareService: ShareService
    
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
        dataService: DataServiceProtocol? = nil,
        readingStatsManager: ReadingStatsManager? = nil
    ) {
        // ✅ Services & Repos
        let dataServiceInstance: DataServiceProtocol = dataService ?? DataService(
            networkService: NetworkService(),
            cacheManager: CacheService()
        )

        self.dataService = dataServiceInstance

        self.articlesRepo = articlesRepo ?? ArticlesRepositoryImpl(dataService: dataServiceInstance)
        self.categoriesRepo = categoriesRepo ?? CategoriesRepositoryImpl(dataService: dataServiceInstance)
        
        // ✅ Managers
        self.favoritesManagerConcrete = favoritesManager ?? FavoritesManager()
        self.ratingManager = ratingManager ?? RatingManager()
        self.textSizeManager = textSizeManager ?? TextSizeManager()
        self.localizationManager = localizationManager ?? LocalizationManager()
        self.readingStatsManager = readingStatsManager ?? ReadingStatsManager()
        
        // ✅ Formatters & Services
        self.articleFormatter = ArticleFormatter(
            dateFormattingService: dateFormattingService,
            textAnalysisService: textAnalysisService
        )
        
        // ✅ ShareService
        self.shareService = ShareService(
            articleFormatter: articleFormatter,
            localizationManager: self.localizationManager
        )
    }
    
    // MARK: - ViewModel Factory Methods
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            favoritesManager: favoritesService,
            readingStatsManager: readingStatsManager,
            categoriesRepository: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            favoritesManager: favoritesService,
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo
        )
    }
    
    func makeCategoriesViewModel() -> CategoriesViewModel {
        CategoriesViewModel(
            categoriesRepo: categoriesRepo,
            articlesRepo: articlesRepo,
            favoritesManager: favoritesService
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesManager: favoritesService,
            articlesRepo: articlesRepo
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            settings: settingsManager,
            localizationManager: localizationManager,
            statsManager: readingStatsService
        )
    }
    
    func makeArticleDetailViewModel(article: Article, allArticles: [Article]) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            localizationManager: localizationManager,
            textSizeManager: textSizeManager,
            favoritesManager: favoritesService,
            ratingManager: ratingManager,
            readingStatsManager: readingStatsService,
            articleFormatter: articleFormatter,
            categoriesRepository: categoriesRepo,
            shareService: shareService,
            articlesProvider: ArticlesProviderAdapter(repo: articlesRepo)
        )
    }
    
    func makeAboutViewModel() -> AboutViewModel {
        AboutViewModel()
    }
    
    func makeArticleRowViewModel(article: Article) -> ArticleRowViewModel {
        ArticleRowViewModel(
            article: article,
            localizationManager: localizationManager,
            favoritesManager: favoritesService,
            ratingManager: ratingManager,
            categoriesRepo: categoriesRepo,
            readingStatsManager: readingStatsService,
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
    
    // MARK: - PDF Library

    func makePDFLibraryViewModel() -> PDFLibraryViewModel {
        let seedItems: [PDFItem] = [
            PDFItem(titleKey: "pdf_title_test1", descriptionKey: "pdf_desc_test1", fileName: "test1"),
            PDFItem(titleKey: "pdf_title_test2", descriptionKey: "pdf_desc_test2", fileName: "test2"),
            PDFItem(titleKey: "pdf_title_test3", descriptionKey: "pdf_desc_test3", fileName: "test3")
        ]
        
        return PDFLibraryViewModel(
            localizationManager: localizationManager,
            items: seedItems
        )
    }

    
 /*   func makeDemoArticleView() -> DemoArticleView {
        DemoArticleView(localizationManager: localizationManager)
    }
  */

    // MARK: - Editor

    func makeArticleEditorViewModel() -> ArticleEditorViewModel {
        // здесь не тянем ничего из .shared — чистый DI
        ArticleEditorViewModel(title: "", blocks: [])
    }

    /*
    func makeArticleEditorView() -> ArticleEditorView {
        ArticleEditorView(viewModel: makeArticleEditorViewModel())
    }
    
     */
    
    func makeShareService() -> ShareServiceProtocol {
        return shareService
    }
    
    func makeArticleLibraryViewModel() -> ArticleLibraryViewModel {
        ArticleLibraryViewModel()
    }
    
    func makeArticleDetailView(article: Article, allArticles: [Article]) -> ArticleDetailView {
        ArticleDetailView(
            viewModel: makeArticleDetailViewModel(article: article, allArticles: allArticles),
            localizationManager: localizationManager,
            articleRowFactory: { article in
                self.makeArticleRowViewModel(article: article)
            }
        )
    }
    
    // MARK: - Global Environment Injection
    
    func provideEnvironmentObjects() -> some View {
        EmptyView()
            .environmentObject(self)
            .environmentObject(favoritesManagerConcrete)
            .environmentObject(textSizeManager)
            .environmentObject(localizationManager)
            .environmentObject(ratingManager)
            .environmentObject(readingStatsManager)
    }
    
    // MARK: - Clear All Data (for testing)
    
    func clearAllData() {
        favoritesManagerConcrete.clearForTesting()
        ratingManager.clearForTesting()
        readingStatsManager.clearHistory()
    }
    
    // MARK: - Bootstrap (non-blocking preload)
    func bootstrap() {
        // ⚡ Инициализируем только локализацию, без подгрузки статей/категорий
        localizationManager.preload()
    }

}

// MARK: - Preview / Mocks

extension AppContainer {
    static func previewMock() -> AppContainer {
        AppContainer()
    }
}
