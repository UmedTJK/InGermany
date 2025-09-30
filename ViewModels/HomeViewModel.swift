//
//  HomeViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = true
    @Published var dataSource: String = "unknown"
    
    @Published var isShowingRandomArticle: Bool = false
    @Published var randomArticle: Article?

    // зависимости
    let favoritesManager: FavoritesManager
    let readingHistoryManager: ReadingHistoryManager
    let categoriesRepository: CategoriesRepository
    
    init(
        favoritesManager: FavoritesManager? = nil,
        readingHistoryManager: ReadingHistoryManager? = nil,
        categoriesRepository: CategoriesRepository? = nil
    ) {
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.readingHistoryManager = readingHistoryManager ?? ReadingHistoryManager.shared
        self.categoriesRepository = categoriesRepository ?? CategoriesRepository.shared
    }
    
    var allCategories: [Category] {
        categoriesRepository.allCategories()
    }
    
    var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles) { $0.categoryId }
    }
    
    // MARK: - Data loading
    
    func loadData() async {
        isLoading = true
        let loaded = await DataService.shared.loadArticles()
        let sources = await DataService.shared.getLastDataSource()
        
        self.articles = loaded
        self.dataSource = sources["articles"] ?? "unknown"
        self.isLoading = false
    }
    
    func refreshData() async {
        isLoading = true
        await DataService.shared.refreshData()
        
        let loaded = await DataService.shared.loadArticles()
        let sources = await DataService.shared.getLastDataSource()
        
        self.articles = loaded
        self.dataSource = sources["articles"] ?? "unknown"
        self.isLoading = false
    }
    
    // MARK: - Random article
    
    func selectRandomArticle() {
        if let article = articles.randomElement() {
            randomArticle = article
            isShowingRandomArticle = true
        }
    }
}
