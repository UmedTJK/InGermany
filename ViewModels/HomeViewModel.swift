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
    let favoritesManager: FavoritesManagingProtocol
    let readingStatsManager: ReadingStatsManagingProtocol
    let categoriesRepository: CategoriesRepositoryProtocol
    let articlesRepo: ArticlesRepositoryProtocol

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
    convenience init() {
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
    // MARK: - Data loading
    func loadData() async {
        let start = Date()
        print("⏱ loadData started at \(start)")

        isLoading = true

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
            self.dataSource = source
            print("⏱ Articles loaded in \(Date().timeIntervalSince(start)) sec")
        }


        // 4. Фоновое обновление из сети
        Task.detached { [weak self] in
            guard let self else { return }
            let fresh = await self.articlesRepo.refreshArticles()
            if !fresh.isEmpty {
                await MainActor.run {
                    self.articles = fresh
                    self.dataSource = "network"
                }
            }
        }
    }
    
    // MARK: - Refresh
    func refreshData() async {
        print("🔄 refreshData triggered from HomeView")
        await categoriesRepository.refresh()
        let refreshed = await articlesRepo.refreshArticles()
        await MainActor.run {
            if !refreshed.isEmpty {
                self.articles = refreshed
                self.dataSource = "network"
            }
        }
    }



    // MARK: - Random article
    func selectRandomArticle() {
        randomArticle = articles.randomElement()
        isShowingRandomArticle = (randomArticle != nil)
    }
}
