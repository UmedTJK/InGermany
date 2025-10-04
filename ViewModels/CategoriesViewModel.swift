//
//  CategoriesViewModel.swift
//  InGermany
//

import Foundation

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var articles: [Article] = []   // ✅ добавлено хранение статей

    private let categoriesRepo: CategoriesRepository
    private let articlesRepo: ArticlesRepository

    // Инжекция зависимостей: можно подменять репозитории (например, на моки в тестах)
    init(categoriesRepo: CategoriesRepository, articlesRepo: ArticlesRepository) {
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
    }

    /// Загрузить категории (инициализация)
    func load() async {
        await categoriesRepo.bootstrap()
        categories = categoriesRepo.allCategories()
    }

    /// Обновить категории
    func refresh() async {
        await categoriesRepo.refresh()
        categories = categoriesRepo.allCategories()
    }

    /// Найти категорию по ID
    func category(by id: String) -> Category? {
        categoriesRepo.category(by: id)
    }

    /// Загрузить все статьи (инициализация)
    func loadArticles() async {
        articles = await articlesRepo.loadArticles()
    }

    /// Получить статьи по ID категории
    func articles(for categoryId: String) -> [Article] {
        return articles.filter { $0.categoryId == categoryId }
    }

    /// Совместимость: метод для вызова из старых вью
    func loadData() async {
        await load()
        await loadArticles()
    }
}
