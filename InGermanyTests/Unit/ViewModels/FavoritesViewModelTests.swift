//
//  FavoritesViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    var sut: FavoritesViewModel!
    var mockService: MockDataService!

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockDataService(
            articlesJSON: """
            [
                {
                    "id": "1",
                    "title": {"en": "Test Article 1"},
                    "content": {"en": "Content"},
                    "categoryId": "c1",
                    "tags": []
                }
            ]
            """
        )
        sut = FavoritesViewModel(
            favoritesManager: FavoritesManager.shared,
            articlesRepo: mockService
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        try await super.tearDown()
    }

    func testLoadFavoritesInitiallyEmpty() async throws {
        XCTAssertTrue(sut.favoriteArticles.isEmpty, "Initially there should be no favorites")
    }

    func testAddToFavorites() async throws {
        await sut.toggleFavorite(for: "1")
        XCTAssertEqual(sut.favoriteArticles.count, 1, "After toggling, favorites should contain the article")
    }

    func testRemoveFromFavorites() async throws {
        await sut.toggleFavorite(for: "1")
        await sut.toggleFavorite(for: "1") // remove again
        XCTAssertTrue(sut.favoriteArticles.isEmpty, "Toggling twice should remove the article from favorites")
    }
}
