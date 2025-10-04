//
//  HomeViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockArticlesRepo: MockArticlesRepository!
    var mockCategoriesRepo: MockCategoriesRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Clean up before each test
        FavoritesManager.shared.clearForTesting()
        ReadingHistoryManager.shared.clearForTesting()
        
        // Create mocks
        mockArticlesRepo = MockArticlesRepository()
        mockCategoriesRepo = MockCategoriesRepository()
        
        // Initialize ViewModel with dependencies
        sut = HomeViewModel(
            favoritesManager: FavoritesManager.shared,
            readingHistoryManager: ReadingHistoryManager.shared,
            categoriesRepository: mockCategoriesRepo,
            articlesRepo: mockArticlesRepo
        )
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        FavoritesManager.shared.clearForTesting()
        ReadingHistoryManager.shared.clearForTesting()
        sut = nil
        mockArticlesRepo = nil
        mockCategoriesRepo = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.articles.isEmpty, "Initially articles should be empty")
        XCTAssertTrue(sut.isLoading, "Initially should be loading")
        XCTAssertEqual(sut.dataSource, "unknown", "Initially dataSource should be unknown")
        XCTAssertFalse(sut.isShowingRandomArticle, "Initially not showing random article")
        XCTAssertNil(sut.randomArticle, "Initially random article should be nil")
    }
    
    // MARK: - Data Loading Tests
    
    func testLoadData() async throws {
        // Given - initial state
        XCTAssertTrue(sut.articles.isEmpty)
        XCTAssertTrue(sut.isLoading)
        
        // When - load data
        await sut.loadData()
        
        // Then - should have loaded articles
        XCTAssertEqual(sut.articles.count, 2, "Should load 2 test articles")
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.dataSource, "mock", "DataSource should be updated")
    }
    
    func testRefreshData() async throws {
        // Given - initial loaded state
        await sut.loadData()
        let initialArticles = sut.articles
        
        // When - refresh data
        await sut.refreshData()
        
        // Then - should still have articles
        XCTAssertEqual(sut.articles.count, initialArticles.count, "Should maintain article count after refresh")
        XCTAssertFalse(sut.isLoading, "Should not be loading after refresh")
        XCTAssertEqual(sut.dataSource, "mock", "DataSource should be updated")
    }
    
    // MARK: - Derived Data Tests
    
    func testAllCategories() async throws {
        // When - categories are available from mock
        let categories = sut.allCategories
        
        // Then - should return mock categories
        XCTAssertEqual(categories.count, 2, "Should return 2 test categories")
        XCTAssertEqual(categories.first?.id, "c1", "First category should be Health")
        XCTAssertEqual(categories.last?.id, "c2", "Last category should be Work")
    }
    
    func testArticlesByCategory() async throws {
        // Given - loaded articles
        await sut.loadData()
        
        // When - get articles by category
        let grouped = sut.articlesByCategory
        
        // Then - should group articles correctly
        XCTAssertEqual(grouped.count, 2, "Should have 2 categories")
        XCTAssertEqual(grouped["c1"]?.count, 1, "Category c1 should have 1 article")
        XCTAssertEqual(grouped["c2"]?.count, 1, "Category c2 should have 1 article")
        XCTAssertEqual(grouped["c1"]?.first?.id, "a1", "Category c1 should contain article a1")
        XCTAssertEqual(grouped["c2"]?.first?.id, "a2", "Category c2 should contain article a2")
    }
    
    // MARK: - Random Article Tests
    
    func testSelectRandomArticleWithArticles() async throws {
        // Given - loaded articles
        await sut.loadData()
        
        // When - select random article
        sut.selectRandomArticle()
        
        // Then - should set random article
        XCTAssertNotNil(sut.randomArticle, "Random article should not be nil")
        XCTAssertTrue(sut.isShowingRandomArticle, "Should be showing random article")
        XCTAssertTrue(["a1", "a2"].contains(sut.randomArticle?.id), "Random article should be one of the test articles")
    }
    
    func testSelectRandomArticleWithEmptyArticles() {
        // Given - no articles loaded
        XCTAssertTrue(sut.articles.isEmpty)
        
        // When - select random article
        sut.selectRandomArticle()
        
        // Then - should not set random article
        XCTAssertNil(sut.randomArticle, "Random article should be nil with empty articles")
        XCTAssertFalse(sut.isShowingRandomArticle, "Should not be showing random article")
    }
    
    // MARK: - Convenience Initializer Test
    
    func testConvenienceInitializer() {
        // When - use convenience init
        let convenienceVM = HomeViewModel()
        
        // Then - should initialize with shared instances
        XCTAssertNotNil(convenienceVM.favoritesManager)
        XCTAssertNotNil(convenienceVM.readingHistoryManager)
        XCTAssertNotNil(convenienceVM.categoriesRepository)
        XCTAssertNotNil(convenienceVM.articlesRepo)
    }
}
