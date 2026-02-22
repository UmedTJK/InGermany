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

    // MARK: - Concurrency guards
    /// Prevents stale async loads from overwriting newer state.
    private var loadGeneration: UInt64 = 0

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
        loadGeneration &+= 1
        let gen = loadGeneration

        await categoriesRepo.bootstrap()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let loadedCategories = categoriesRepo.allCategories()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let loadedArticles = await articlesRepo.loadArticles()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        guard gen == loadGeneration else { return }
        self.categories = loadedCategories
        self.articles = loadedArticles
    }

    /// Обновить категории
    func refresh() async {
        loadGeneration &+= 1
        let gen = loadGeneration

        await categoriesRepo.refresh()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let refreshedCategories = categoriesRepo.allCategories()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let refreshedArticles = await articlesRepo.refreshArticles()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        guard gen == loadGeneration else { return }
        self.categories = refreshedCategories
        self.articles = refreshedArticles
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
