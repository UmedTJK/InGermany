import Foundation
@testable import InGermany

/// Мок-сервис данных для тестов
@MainActor
final class MockDataService {
    let articlesRepository: ArticlesRepositoryProtocol
    let categoriesRepository: CategoriesRepositoryProtocol
    
    // MARK: - Инициализаторы для тестов
    init(articlesRepository: ArticlesRepositoryProtocol, categoriesRepository: CategoriesRepositoryProtocol) {
        self.articlesRepository = articlesRepository
        self.categoriesRepository = categoriesRepository
    }
    
    convenience init(articlesJSON: String) {
        let data = Data(articlesJSON.utf8)
        let articles = (try? JSONDecoder().decode([InGermany.Article].self, from: data)) ?? []
        
        let mockArticlesRepo = MockArticlesRepository()
        // Устанавливаем статьи в мок-репозиторий
        mockArticlesRepo.setArticles(articles)
        
        self.init(
            articlesRepository: mockArticlesRepo,
            categoriesRepository: MockCategoriesRepository()
        )
    }

    convenience init(categoriesJSON: String) {
        let data = Data(categoriesJSON.utf8)
        let categories = (try? JSONDecoder().decode([InGermany.Category].self, from: data)) ?? []
        
        let mockCategoriesRepo = MockCategoriesRepository()
        mockCategoriesRepo.categories = categories
        
        self.init(
            articlesRepository: MockArticlesRepository(),
            categoriesRepository: mockCategoriesRepo
        )
    }

    // MARK: - Методы для статей
    func loadArticles() async -> [Article] {
        await articlesRepository.loadArticles()
    }

    func refreshArticles() async -> [Article] {
        await articlesRepository.refreshArticles()
    }

    func getLastSource() -> String {
        // Note: Это свойство есть только у ArticlesRepositoryProtocol
        if let articlesRepo = articlesRepository as? MockArticlesRepository {
            return articlesRepo.getLastSource()
        }
        return "mock"
    }

    // MARK: - Методы для категорий
    func loadCategories() async -> [InGermany.Category] {
        categoriesRepository.allCategories()
    }

    func refreshCategories() async -> [InGermany.Category] {
        categoriesRepository.allCategories()
    }
}
