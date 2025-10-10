//
//  HomeViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages state and actions for the home screen, including articles, categories, favorites, and random article selection.
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - UI State
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = true
    @Published var dataSource: String = "unknown"
    @Published var isShowingRandomArticle: Bool = false
    @Published var randomArticle: Article?

    // MARK: - Dependencies
    let favoritesManager: FavoritesManager
    let readingStatsManager: ReadingStatsManaging
    let categoriesRepository: CategoriesRepositoryProtocol
    let articlesRepo: ArticlesRepositoryProtocol

    // Локализация
    private let localizationManager: LocalizationManager

    // MARK: - Init
    init(
        favoritesManager: FavoritesManager,
        readingStatsManager: ReadingStatsManaging,
        categoriesRepository: CategoriesRepositoryProtocol,
        articlesRepo: ArticlesRepositoryProtocol,
        localizationManager: LocalizationManager = LocalizationManager.shared
    ) {
        self.favoritesManager = favoritesManager
        self.readingStatsManager = readingStatsManager
        self.categoriesRepository = categoriesRepository
        self.articlesRepo = articlesRepo
        self.localizationManager = localizationManager
    }

    // MARK: - Convenience init (Preview)
    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            readingStatsManager: ReadingStatsManager.shared,
            categoriesRepository: DefaultCategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl(dataService: DataService.shared),
            localizationManager: LocalizationManager.shared
        )
    }

    // MARK: - Derived data
    var allCategories: [Category] {
        categoriesRepository.allCategories()
    }

    var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles, by: { $0.categoryId })
    }

    /// Возвращает локализованное имя категории по ID или "Без категории".
    func categoryName(for id: String, language: String) -> String {
        if let category = categoriesRepository.category(by: id) {
            return category.localizedName(for: language)
        } else {
            return localizationManager.getTranslation(key: "category_none", language: language)
        }
    }

    // MARK: - Data loading
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.loadArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }

    func refreshData() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.refreshArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }

    // MARK: - Random article
    func selectRandomArticle() {
        randomArticle = articles.randomElement()
        isShowingRandomArticle = (randomArticle != nil)
    }
}
