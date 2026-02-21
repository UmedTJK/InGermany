//
//  HomeViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages state and actions for the home screen, including articles, categories, favorites, and random article selection.
class HomeViewModel: ObservableObject {
    // MARK: - UI State
    @MainActor @Published var articles: [Article] = []
    @MainActor @Published var isLoading: Bool = true
    @MainActor @Published var dataSource: String = "unknown"
    @MainActor @Published var isShowingRandomArticle: Bool = false
    @MainActor @Published var randomArticle: Article?

    // MARK: - Dependencies
    let favoritesManager: FavoritesManagingProtocol
    let readingStatsManager: ReadingStatsManagingProtocol
    let categoriesRepository: CategoriesRepositoryProtocol
    let articlesRepo: ArticlesRepositoryProtocol

    // MARK: - Tasks (lifecycle-bound)
    private var backgroundRefreshTask: Task<Void, Never>?
    deinit { backgroundRefreshTask?.cancel() }

    // Локализация
    private let localizationManager: LocalizationManager

    // MARK: - Init
    init(
        favoritesManager: FavoritesManagingProtocol,
        readingStatsManager: ReadingStatsManagingProtocol,
        categoriesRepository: CategoriesRepositoryProtocol,
        articlesRepo: ArticlesRepositoryProtocol,
        localizationManager: LocalizationManager
    ) {
        self.favoritesManager = favoritesManager
        self.readingStatsManager = readingStatsManager
        self.categoriesRepository = categoriesRepository
        self.articlesRepo = articlesRepo
        self.localizationManager = localizationManager
    }

    // MARK: - Convenience init (Preview)
    @MainActor convenience init() {
        let network = NetworkService()
        let cache = CacheService()
        let dataService = DataService(networkService: network, cacheManager: cache)
        
        self.init(
            favoritesManager: FavoritesManager(),
            readingStatsManager: ReadingStatsManager(),
            categoriesRepository: CategoriesRepositoryImpl(dataService: dataService),
            articlesRepo: ArticlesRepositoryImpl(dataService: dataService),
            localizationManager: LocalizationManager()
        )
    }

    // MARK: - Derived data
    @MainActor var allCategories: [Category] {
        categoriesRepository.allCategories()
    }

    @MainActor @Published private(set) var articlesByCategory: [String: [Article]] = [:]
    @MainActor private func rebuildArticlesByCategory(from articles: [Article]) {
        self.articlesByCategory = Dictionary(grouping: articles, by: { $0.categoryId })
    }

    /// Возвращает локализованное имя категории по ID или "Без категории".
    @MainActor func categoryName(for id: String, language: String) -> String {
        if let category = categoriesRepository.category(by: id) {
            return category.localizedName(for: language)
        } else {
            return localizationManager.getTranslation(key: "category_none", language: language)
        }
    }

    // MARK: - Data loading
    func loadData() async {
        let start = Date()
        print("⏱ loadData started at \(start)")

        await MainActor.run { self.isLoading = true }

        // 1. Сначала bootstrap категорий (быстро)
        await categoriesRepository.bootstrap()

        // 2. UI готов к показу
        await MainActor.run {
            self.isLoading = false
            print("⏱ UI ready in \(Date().timeIntervalSince(start)) sec")
        }

        // 3. Параллельно загружаем статьи
        let articles = await articlesRepo.loadArticles()
        let source = await articlesRepo.getLastSource()

        await MainActor.run {
            self.articles = articles
            self.rebuildArticlesByCategory(from: articles)
            self.dataSource = source
            print("⏱ Articles loaded in \(Date().timeIntervalSince(start)) sec")
        }

        // 4. Фоновое обновление из сети (только если первичная загрузка была НЕ из сети)
        if source != "network", !Task.isCancelled {
            backgroundRefreshTask?.cancel()
            backgroundRefreshTask = Task(priority: .background) { [weak self] in
                guard let self else { return }
                guard !Task.isCancelled else { return }

                let fresh = await self.articlesRepo.refreshArticles()
                guard !Task.isCancelled else { return }

                if !fresh.isEmpty {
                    await MainActor.run {
                        self.articles = fresh
                        self.rebuildArticlesByCategory(from: fresh)
                        self.dataSource = "network"
                    }
                }
            }
        }
    }

    // MARK: - Refresh
    func refreshData() async {
        guard !Task.isCancelled else { return }
        print("🔄 refreshData triggered from HomeView")
        await categoriesRepository.refresh()
        let refreshed = await articlesRepo.refreshArticles()
        guard !Task.isCancelled else { return }
        await MainActor.run {
            if !refreshed.isEmpty {
                self.articles = refreshed
                self.rebuildArticlesByCategory(from: refreshed)
                self.dataSource = "network"
            }
        }
    }

    // MARK: - Random article
    @MainActor func selectRandomArticle() {
        randomArticle = articles.randomElement()
        isShowingRandomArticle = (randomArticle != nil)
    }
}
