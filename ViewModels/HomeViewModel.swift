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
    // MARK: - Concurrency guards
    /// Monotonic token to prevent stale async results from overwriting newer loads.
    private var loadGeneration: UInt64 = 0

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
        // New generation for this run; older tasks must not commit state.
        loadGeneration &+= 1
        let gen = loadGeneration

        let start = Date()
        print("⏱ loadData started at \(start) [gen=\(gen)]")

        guard !Task.isCancelled else { return }
        await MainActor.run {
            // Only the latest generation may mutate UI state.
            guard gen == self.loadGeneration else { return }
            self.isLoading = true
        }

        // 1) Bootstrap categories (fast)
        await categoriesRepository.bootstrap()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        // 2) UI ready
        await MainActor.run {
            guard gen == self.loadGeneration else { return }
            self.isLoading = false
            print("⏱ UI ready in \(Date().timeIntervalSince(start)) sec [gen=\(gen)]")
        }

        // 3) Load articles (may hit disk/cache)
        let articles = await articlesRepo.loadArticles()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let source = await articlesRepo.getLastSource()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        await MainActor.run {
            guard gen == self.loadGeneration else { return }
            self.articles = articles
            self.rebuildArticlesByCategory(from: articles)
            self.dataSource = source
            print("⏱ Articles loaded in \(Date().timeIntervalSince(start)) sec [gen=\(gen)]")
        }

        // 4) Background refresh from network (only if initial load was NOT from network)
        guard source != "network", !Task.isCancelled, gen == loadGeneration else { return }

        backgroundRefreshTask?.cancel()
        backgroundRefreshTask = Task(priority: .background) { [weak self] in
            guard let self else { return }
            guard !Task.isCancelled else { return }
            // If a newer load started, abort.
            guard gen == self.loadGeneration else { return }

            let fresh = await self.articlesRepo.refreshArticles()
            guard !Task.isCancelled else { return }
            guard gen == self.loadGeneration else { return }

            if !fresh.isEmpty {
                await MainActor.run {
                    guard gen == self.loadGeneration else { return }
                    self.articles = fresh
                    self.rebuildArticlesByCategory(from: fresh)
                    self.dataSource = "network"
                }
            }
        }
    }

    // MARK: - Refresh
    func refreshData() async {
        // Treat pull-to-refresh as a new authoritative generation.
        loadGeneration &+= 1
        let gen = loadGeneration

        guard !Task.isCancelled else { return }
        print("🔄 refreshData triggered from HomeView [gen=\(gen)]")

        await categoriesRepository.refresh()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let refreshed = await articlesRepo.refreshArticles()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        await MainActor.run {
            guard gen == self.loadGeneration else { return }
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
