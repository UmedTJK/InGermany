//
//  HomeViewModel.swift
//  InGermany
//

import SwiftUI

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
    let readingHistoryManager: ReadingHistoryManager
    let categoriesRepository: CategoriesRepository
    private let articlesRepo: ArticlesRepository

    // MARK: - Designated init (главный инициализатор, используется DI/контейнером)
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
    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            readingHistoryManager: ReadingHistoryManager.shared,
            categoriesRepository: CategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    // MARK: - Derived data
    var allCategories: [Category] {
        categoriesRepository.allCategories()
    }

    var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles, by: { $0.categoryId })
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
