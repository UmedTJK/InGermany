//
//  FavoritesViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    var sut: FavoritesViewModel!
    var mockArticlesRepo: MockArticlesRepository!

    override func setUp() async throws {
        try await super.setUp()
        
        // Clean up favorites before each test
        FavoritesManager.shared.clearForTesting()
        
        // Create mock repository
        mockArticlesRepo = MockArticlesRepository()
        
        // Initialize ViewModel with real FavoritesManager and mock repository
        sut = FavoritesViewModel(
            favoritesManager: FavoritesManager.shared,
            articlesRepo: mockArticlesRepo
        )
    }

    override func tearDown() async throws {
        // Clean up after each test
        FavoritesManager.shared.clearForTesting()
        sut = nil
        mockArticlesRepo = nil
        try await super.tearDown()
    }

    func testLoadFavoritesInitiallyEmpty() async throws {
        // Given - initial state
        XCTAssertTrue(sut.favoriteArticles.isEmpty, "Initially there should be no favorites")
        XCTAssertTrue(sut.isLoading, "Initially should be loading")
        
        // When - load favorites
        await sut.loadFavorites()
        
        // Then - should still be empty since no articles are favorited
        XCTAssertTrue(sut.favoriteArticles.isEmpty, "After loading, favorites should still be empty")
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.dataSource, "mock", "DataSource should be updated to 'mock'")
    }

    func testAddToFavorites() async throws {
        // Given - load articles first
        await sut.loadFavorites()
        let initialCount = sut.favoriteArticles.count
        
        // When - toggle favorite
        sut.toggleFavorite(for: "a1")
        
        // Then - should contain the article
        XCTAssertEqual(sut.favoriteArticles.count, initialCount + 1, "After toggling, favorites count should increase by 1")
        XCTAssertEqual(sut.favoriteArticles.first?.id, "a1", "Favorite article should have id 'a1'")
        XCTAssertTrue(FavoritesManager.shared.isFavorite("a1"), "FavoritesManager should reflect the favorite status")
    }

    func testRemoveFromFavorites() async throws {
        // Given - load articles and add to favorites
        await sut.loadFavorites()
        sut.toggleFavorite(for: "a1")
        let countAfterAdd = sut.favoriteArticles.count
        
        // When - toggle again to remove
        sut.toggleFavorite(for: "a1")
        
        // Then - should be empty again
        XCTAssertEqual(sut.favoriteArticles.count, countAfterAdd - 1, "Toggling twice should remove the article from favorites")
        XCTAssertFalse(FavoritesManager.shared.isFavorite("a1"), "FavoritesManager should reflect the removal")
    }
    
    func testLoadingState() async throws {
        // Given - initial loading state
        XCTAssertTrue(sut.isLoading, "Initially should be loading")
        
        // When - load favorites
        await sut.loadFavorites()
        
        // Then - should not be loading anymore
        XCTAssertFalse(sut.isLoading, "After loading, should not be loading")
    }
    
    func testDataSource() async throws {
        // Given - initial state
        XCTAssertEqual(sut.dataSource, "unknown", "Initially dataSource should be unknown")
        
        // When - load favorites
        await sut.loadFavorites()
        
        // Then - dataSource should be updated
        XCTAssertEqual(sut.dataSource, "mock", "DataSource should be updated after loading")
    }
    
    func testMultipleFavorites() async throws {
        // Given - load articles
        await sut.loadFavorites()
        
        // When - add multiple favorites
        sut.toggleFavorite(for: "a1")
        sut.toggleFavorite(for: "a2")
        
        // Then - should contain both articles
        XCTAssertEqual(sut.favoriteArticles.count, 2, "Should contain 2 favorite articles")
        XCTAssertTrue(sut.favoriteArticles.contains { $0.id == "a1" }, "Should contain article a1")
        XCTAssertTrue(sut.favoriteArticles.contains { $0.id == "a2" }, "Should contain article a2")
    }
    
    func testAllArticlesLoaded() async throws {
        // When - load favorites
        await sut.loadFavorites()
        
        // Then - all articles should be loaded
        XCTAssertEqual(sut.allArticles.count, 2, "Should load all 2 test articles")
        XCTAssertTrue(sut.allArticles.contains { $0.id == "a1" }, "Should contain article a1 in all articles")
        XCTAssertTrue(sut.allArticles.contains { $0.id == "a2" }, "Should contain article a2 in all articles")
    }
}
