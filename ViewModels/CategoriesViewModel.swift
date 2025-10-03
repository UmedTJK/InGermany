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

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = true

    let favoritesManager: FavoritesManager
    private let categoriesRepo: CategoriesRepository
    private let articlesRepo: ArticlesRepository

    init(
        favoritesManager: FavoritesManager,
        categoriesRepo: CategoriesRepository,
        articlesRepo: ArticlesRepository
    ) {
        self.favoritesManager = favoritesManager
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
    }

    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            categoriesRepo: CategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        await categoriesRepo.bootstrap()
        self.categories = categoriesRepo.categories
        self.articles = await articlesRepo.loadArticles()
    }
}
