//
//  MockArticlesRepository..swift
//  InGermany
//
//  Created by SUM TJK on 04.10.25.
//
//
@testable import InGermany

@MainActor
final class MockArticlesRepository: ArticlesRepositoryProtocol {
    private var mockArticles: [Article] = [
        Article(id: "a1", title: ["en": "A1"], content: ["en": "Text A1"], categoryId: "c1", tags: []),
        Article(id: "a2", title: ["en": "A2"], content: ["en": "Text A2"], categoryId: "c2", tags: [])
    ]
    
    // Добавляем возможность изменять данные для тестов
    func setArticles(_ articles: [Article]) {
        self.mockArticles = articles
    }

    func loadArticles() async -> [Article] {
        return mockArticles
    }

    func refreshArticles() async -> [Article] {
        return mockArticles
    }

    func getLastSource() -> String {
        return "mock"
    }
}
