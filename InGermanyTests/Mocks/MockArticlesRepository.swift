//
//  MockArticlesRepository..swift
//  InGermany
//
//  Created by SUM TJK on 04.10.25.
//
@testable import InGermany

@MainActor
final class MockArticlesRepository: ArticlesRepository {
    func loadArticles() async -> [Article] {
        [
            Article(id: "a1", title: ["en": "A1"], content: ["en": "Text A1"], categoryId: "c1", tags: []),
            Article(id: "a2", title: ["en": "A2"], content: ["en": "Text A2"], categoryId: "c2", tags: [])
        ]
    }

    func refreshArticles() async -> [Article] {
        return await loadArticles()
    }

    func getLastSource() async -> String {
        return "mock"
    }
}
