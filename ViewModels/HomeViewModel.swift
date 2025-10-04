//
//  HomeViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages state and actions for the home screen, including articles, categories, favorites, and random article selection.
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - UI State
    /// The list of loaded articles.
    @Published var articles: [Article] = []
    /// Indicates whether data is currently being loaded.
    @Published var isLoading: Bool = true
    /// Describes the source of the last data load (e.g., cache, local, network).
    @Published var dataSource: String = "unknown"

    /// Flag showing whether a random article is being displayed.
    @Published var isShowingRandomArticle: Bool = false
    /// The currently selected random article, if any.
    @Published var randomArticle: Article?

    // MARK: - Dependencies
    /// Manager for handling favorite articles.
    let favoritesManager: FavoritesManager
    /// Manager for tracking reading history.
    let readingHistoryManager: ReadingHistoryManager
    /// Repository for accessing categories.
    let categoriesRepository: CategoriesRepository
    /// Repository for loading and refreshing articles.
    private let articlesRepo: ArticlesRepository

    // MARK: - Designated init (главный инициализатор, используется DI/контейнером)
    /// Designated initializer injecting managers and repositories for dependency management.
    init(
        favoritesManager: FavoritesManager,
        readingHistoryManager: ReadingHistoryManager,
        categoriesRepository: CategoriesRepository,
        articlesRepo: ArticlesRepository
    ) {
        self.favoritesManager = favoritesManager
        self.readingHistoryManager = readingHistoryManager
        self.categoriesRepository = categoriesRepository
        self.articlesRepo = articlesRepo
    }

    // MARK: - Convenience init (для превью и старых вызовов)
    /// Convenience initializer using shared singletons for previews and default usage.
    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            readingHistoryManager: ReadingHistoryManager.shared,
            categoriesRepository: DefaultCategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    // MARK: - Derived data
    /// Returns all available categories from the repository.
    var allCategories: [Category] {
        categoriesRepository.allCategories()
    }

    /// Groups articles by category ID.
    var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles, by: { $0.categoryId })
    }

    // MARK: - Data loading
    /// Loads articles asynchronously and updates state.
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.loadArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }

    /// Refreshes articles by clearing cache and reloading from the repository.
    func refreshData() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.refreshArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }

    // MARK: - Random article
    /// Selects a random article and updates related state.
    func selectRandomArticle() {
        randomArticle = articles.randomElement()
        isShowingRandomArticle = (randomArticle != nil)
    }
}
