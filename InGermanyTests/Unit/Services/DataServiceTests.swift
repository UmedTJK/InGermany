import XCTest
@testable import InGermany

protocol DataServiceProtocol {
    func loadArticles() async -> [Article]
    func loadCategories() async -> [InGermany.Category]
}

actor MockDataService: DataServiceProtocol {
    private let articlesJSON: String
    private let categoriesJSON: String

    init(articlesJSON: String = "[]", categoriesJSON: String = "[]") {
        self.articlesJSON = articlesJSON
        self.categoriesJSON = categoriesJSON
    }

    func loadArticles() async -> [Article] {
        guard let data = articlesJSON.data(using: .utf8) else {
            return []
        }
        do {
            let articles = try JSONDecoder().decode([Article].self, from: data)
            return articles
        } catch {
            return []
        }
    }

    func loadCategories() async -> [InGermany.Category] {
        guard let data = categoriesJSON.data(using: .utf8) else {
            return []
        }
        do {
            let categories = try JSONDecoder().decode([InGermany.Category].self, from: data)
            return categories
        } catch {
            return []
        }
    }
}

final class DataServiceTests: XCTestCase {

    func testLoadArticlesReturnsArticles() async {
        let articlesJSON = """
        [
            {
                "id": "1",
                "title": { "en": "Test Article" },
                "content": { "en": "This is a test article." },
                "categoryId": "10",
                "tags": []
            }
        ]
        """
        let mockDataService = MockDataService(articlesJSON: articlesJSON)
        let articles = await mockDataService.loadArticles()
        XCTAssertFalse(articles.isEmpty, "Articles should not be empty")
        XCTAssertEqual(articles.first?.id, "1")
        XCTAssertEqual(articles.first?.title["en"], "Test Article")
        XCTAssertEqual(articles.first?.content["en"], "This is a test article.")
        XCTAssertEqual(articles.first?.categoryId, "10")
        XCTAssertEqual(articles.first?.tags.count, 0)
    }

    func testLoadCategoriesReturnsCategories() async {
        let categoriesJSON = """
        [
            {
                "id": "11111111-1111-1111-1111-aaaaaaaaaaaa",
                "name": { "en": "Test Category" },
                "icon": "test-icon",
                "colorHex": "#123456"
            }
        ]
        """
        let mockDataService = MockDataService(categoriesJSON: categoriesJSON)
        let categories = await mockDataService.loadCategories()
        XCTAssertFalse(categories.isEmpty, "Categories should not be empty")
        XCTAssertEqual(categories.first?.id, "11111111-1111-1111-1111-aaaaaaaaaaaa")
        XCTAssertEqual(categories.first?.name["en"], "Test Category")
        XCTAssertEqual(categories.first?.icon, "test-icon")
        XCTAssertEqual(categories.first?.colorHex, "#123456")
    }
}
