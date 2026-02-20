//
//  CategoriesViewModel.swift
//  InGermany
//

import Foundation

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var articles: [Article] = []

    private let categoriesRepo: CategoriesRepositoryProtocol
    private let articlesRepo: ArticlesRepositoryProtocol
    let favoritesManager: FavoritesManagingProtocol

    /// Инжекция зависимостей: можно подменять репозитории (например, на моки в тестах)
    init(
        categoriesRepo: CategoriesRepositoryProtocol,
        articlesRepo: ArticlesRepositoryProtocol,
        favoritesManager: FavoritesManagingProtocol
    ) {
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
        self.favoritesManager = favoritesManager
    }

    /// Загрузить категории (инициализация)
    func load() async {
        await categoriesRepo.bootstrap()
        categories = categoriesRepo.allCategories()
        articles = await articlesRepo.loadArticles()
    }

    /// Обновить категории
    func refresh() async {
        await categoriesRepo.refresh()
        categories = categoriesRepo.allCategories()
        articles = await articlesRepo.refreshArticles()
    }

    /// Найти категорию по ID
    func category(by id: String) -> Category? {
        categoriesRepo.category(by: id)
    }

    /// Получить статьи по ID категории
    func articles(for categoryId: String) -> [Article] {
        return articles.filter { $0.categoryId == categoryId }
    }

    /// Совместимость: метод для вызова из старых вью
    func loadData() async {
        await refresh()
    }
}
