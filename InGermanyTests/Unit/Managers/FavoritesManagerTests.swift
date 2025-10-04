//
//  FavoritesManagerTests.swift
//  InGermanyTests
//
//  Created by SUM TJK on 04.10.25.
//

import XCTest
@testable import InGermany

@MainActor
final class FavoritesManagerTests: XCTestCase {

    var sut: FavoritesManager!

    override func setUp() async throws {
        sut = FavoritesManager.shared
        // Очистим избранное, убрав все текущие id
        for id in Array(sut.favorites) {
            sut.toggleFavorite(for: id)
        }
    }

    override func tearDown() async throws {
        // Очистим снова после тестов
        for id in Array(sut.favorites) {
            sut.toggleFavorite(for: id)
        }
        sut = nil
    }

    func testToggleFavoriteAddsArticle() async throws {
        let articleId = "test-article-1"

        XCTAssertFalse(sut.isFavorite(articleId), "Initially, article should not be favorite")

        sut.toggleFavorite(for: articleId)

        XCTAssertTrue(sut.isFavorite(articleId), "Article should be marked as favorite after toggle")
    }

    func testToggleFavoriteRemovesArticle() async throws {
        let articleId = "test-article-2"

        sut.toggleFavorite(for: articleId)
        XCTAssertTrue(sut.isFavorite(articleId), "Article should be favorite after first toggle")

        sut.toggleFavorite(for: articleId)
        XCTAssertFalse(sut.isFavorite(articleId), "Article should not be favorite after second toggle")
    }

    func testFavoriteArticlesReturnsOnlyFavorites() async throws {
        let article1 = Article(
            id: "a1",
            title: ["en": "First Article"],
            content: ["en": "Content 1"],
            categoryId: "c1",
            tags: []
        )
        let article2 = Article(
            id: "a2",
            title: ["en": "Second Article"],
            content: ["en": "Content 2"],
            categoryId: "c2",
            tags: []
        )

        sut.toggleFavorite(for: article1.id)

        let result = sut.favoriteArticles(from: [article1, article2])

        XCTAssertEqual(result.count, 1, "Only one article should be returned as favorite")
        XCTAssertEqual(result.first?.id, article1.id, "The returned article should match the favorited article")
    }
}
