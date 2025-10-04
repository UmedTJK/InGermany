//
//  CategoriesViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
//
//  CategoriesViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages loading and state for categories and related articles.
@MainActor
class CategoriesViewModel: ObservableObject {
    /// The list of available categories.
    @Published var categories: [Category] = []
    /// The list of articles associated with categories.
    @Published var articles: [Article] = []
    /// Flag indicating whether data is currently being loaded.
    @Published var isLoading: Bool = true

    /// Менеджер избранных статей, используемый для пометки статей
    let favoritesManager: FavoritesManager
    private let categoriesRepo: CategoriesRepository
    private let articlesRepo: ArticlesRepository

    /// Injects dependencies for favorites, categories, and articles repositories.
    init(
        favoritesManager: FavoritesManager,
        categoriesRepo: CategoriesRepository,
        articlesRepo: ArticlesRepository
    ) {
        self.favoritesManager = favoritesManager
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
    }

    /// Uses shared singletons as defaults.
    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            categoriesRepo: CategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    /// Загружает категории и статьи асинхронно, обновляет состояние `isLoading`.
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        await categoriesRepo.bootstrap()
        self.categories = categoriesRepo.categories
        self.articles = await articlesRepo.loadArticles()
    }
}
