import Foundation
@testable import InGermany

/// Мок-репозиторий для тестов
final class MockDataService: ArticlesRepository {
    private var articles: [Article]
    private var categories: [InGermany.Category]

    // MARK: - Инициализаторы для тестов
    init(articlesJSON: String) {
        let data = Data(articlesJSON.utf8)
        self.articles = (try? JSONDecoder().decode([Article].self, from: data)) ?? []
        self.categories = []
    }

    init(categoriesJSON: String) {
        let data = Data(categoriesJSON.utf8)
        self.categories = (try? JSONDecoder().decode([InGermany.Category].self, from: data)) ?? []
        self.articles = []
    }

    // MARK: - ArticlesRepository
    func loadArticles() async -> [Article] {
        articles
    }

    func refreshArticles() async -> [Article] {
        articles
    }

    func getLastSource() async -> String {
        "mock"
    }

    // MARK: - Методы для категорий (используются в VM-тестах)
    func loadCategories() async -> [InGermany.Category] {
        categories
    }

    func refreshCategories() async -> [InGermany.Category] {
        categories
    }
    
    var refreshedArticles: [Article] {
        get { return [] }
        set { }
    }
    
    var lastDataSource: [String: String?] {
        get { return [:] }
        set { }
    }
    
    var onRefreshData: (() -> Void)? {
        get { return nil }
        set { }
    }
    
    
}


