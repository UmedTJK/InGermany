//
//  SearchViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class SearchViewModelTests: XCTestCase {
    var sut: SearchViewModel!
    var mockArticlesRepo: MockArticlesRepository!
    var mockCategoriesRepo: MockCategoriesRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Clean up before each test
        FavoritesManager.shared.clearForTesting()
        
        // Create mocks
        mockArticlesRepo = MockArticlesRepository()
        mockCategoriesRepo = MockCategoriesRepository()
        
        // Initialize ViewModel with dependencies - исправлены названия параметров
        sut = SearchViewModel(
            favoritesManager: FavoritesManager.shared,
            categoriesRepo: mockCategoriesRepo, // было categoriesRepository
            articlesRepo: mockArticlesRepo
        )
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        FavoritesManager.shared.clearForTesting()
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
        XCTAssertTrue(sut.searchText.isEmpty, "Initially search text should be empty")
        XCTAssertNil(sut.selectedTag, "Initially selected tag should be nil")
    }
    
    // MARK: - Data Loading Tests
    
    func testLoadData() async throws {
        // Given - initial state
        XCTAssertTrue(sut.articles.isEmpty)
        
        // When - load data - исправлено название метода
        await sut.loadArticles() // было loadData()
        
        // Then - should have loaded articles
        XCTAssertEqual(sut.articles.count, 2, "Should load 2 test articles")
        XCTAssertFalse(sut.isLoading, "Should not be loading after completion")
        XCTAssertEqual(sut.dataSource, "mock", "DataSource should be updated")
    }
    
    // MARK: - Search Functionality Tests
    
    func testFilteredArticlesWithEmptySearch() async throws {
        // Given - loaded articles and empty search
        await sut.loadArticles() // было loadData()
        
        // When - no search text
        sut.searchText = ""
        
        // Then - should return all articles
        XCTAssertEqual(sut.filteredArticles.count, 2, "Should return all articles with empty search")
    }
    
    func testFilteredArticlesWithSearchText() async throws {
        // Given - loaded articles
        await sut.loadArticles() // было loadData()
        
        // When - search for specific text
        sut.searchText = "A1"
        
        // Then - should filter articles
        XCTAssertEqual(sut.filteredArticles.count, 1, "Should filter to 1 article")
        XCTAssertEqual(sut.filteredArticles.first?.id, "a1", "Should return article A1")
    }
    
    func testFilteredArticlesWithCaseInsensitiveSearch() async throws {
        // Given - loaded articles
        await sut.loadArticles() // было loadData()
        
        // When - search with different case
        sut.searchText = "a1"
        
        // Then - should still find the article (case insensitive)
        XCTAssertEqual(sut.filteredArticles.count, 1, "Should be case insensitive")
        XCTAssertEqual(sut.filteredArticles.first?.id, "a1", "Should return article A1")
    }
    
    func testFilteredArticlesWithNoResults() async throws {
        // Given - loaded articles
        await sut.loadArticles() // было loadData()
        
        // When - search for non-existent text
        sut.searchText = "Nonexistent"
        
        // Then - should return empty results
        XCTAssertTrue(sut.filteredArticles.isEmpty, "Should return empty for no matches")
    }
    
    // MARK: - Tag Filtering Tests
    
    func testAllTags() async throws {
        // Given - loaded articles (mock articles have empty tags)
        await sut.loadArticles() // было loadData()
        
        // When - get all tags
        let tags = sut.allTags
        
        // Then - should return empty array (mock articles have no tags)
        XCTAssertTrue(tags.isEmpty, "Should return empty tags for mock data")
    }
    
    func testFilteredArticlesWithSelectedTag() async throws {
        // Given - loaded articles and selected tag
        await sut.loadArticles() // было loadData()
        
        // When - select a tag (though mock has no tags)
        sut.selectedTag = "test"
        
        // Then - should still handle gracefully
        // Since mock articles have no tags, filtered articles should be empty
        XCTAssertTrue(sut.filteredArticles.isEmpty, "Should handle tags gracefully")
    }
    
    func testClearSelectedTag() async throws {
        // Given - selected tag
        await sut.loadArticles() // было loadData()
        sut.selectedTag = "test"
        
        // When - clear selected tag
        sut.selectedTag = nil
        
        // Then - should clear selection
        XCTAssertNil(sut.selectedTag, "Should clear selected tag")
    }
    
    // MARK: - Combined Search and Tag Tests
    
    func testSearchAndTagCombination() async throws {
        // Given - loaded articles
        await sut.loadArticles() // было loadData()
        
        // When - set both search text and tag
        sut.searchText = "A1"
        sut.selectedTag = "test" // This will filter out all since no tags match
        
        // Then - should apply both filters
        XCTAssertTrue(sut.filteredArticles.isEmpty, "Should apply both search and tag filters")
    }
    
    // MARK: - Convenience Initializer Test
    
    func testConvenienceInitializer() {
        // When - use convenience init
        let convenienceVM = SearchViewModel()
        
        // Then - should initialize with shared instances
        XCTAssertNotNil(convenienceVM.favoritesManager)
        // categoriesRepo и articlesRepo приватные, поэтому не проверяем напрямую
    }
}
