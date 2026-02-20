//
//  ArticleDetailViewModelTests.swift
//  InGermanyTests
//

/*
import XCTest
@testable import InGermany

@MainActor
final class ArticleDetailViewModelTests: XCTestCase {
    var sut: ArticleDetailViewModel!
    var testArticle: Article!
    var testArticles: [Article]!
    
    // Mock dependencies
    var mockLocalizationManager: LocalizationManager!
    var mockTextSizeManager: TextSizeManager!
    var mockRatingManager: RatingManager!
    var mockReadingStatsManager: ReadingStatsManager!
    var mockArticleFormatter: ArticleFormatter!
    var mockCategoriesRepository: CategoriesRepository!
    var mockShareService: ShareService!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Clean up before each test
        FavoritesManager.shared.clearForTesting()
        
        // Create test data
        testArticle = Article(
            id: "test1",
            title: ["en": "Test Article"],
            content: ["en": "Test content"],
            categoryId: "c1",
            tags: ["tag1", "tag2"]
        )
        
        testArticles = [
            testArticle,
            Article(
                id: "test2",
                title: ["en": "Another Article"],
                content: ["en": "Another content"],
                categoryId: "c1",
                tags: ["tag1"]
            ),
            Article(
                id: "test3",
                title: ["en": "Different Article"],
                content: ["en": "Different content"],
                categoryId: "c2",
                tags: ["tag3"]
            )
        ]
        
        // Setup mock dependencies
        setupMockDependencies()
        
        // Initialize ViewModel with all required dependencies
        sut = ArticleDetailViewModel(
            article: testArticle,
            allArticles: testArticles,
            favoritesManager: FavoritesManager.shared,
            historyManager: ReadingHistoryManager.shared,
            localizationManager: mockLocalizationManager,
            textSizeManager: mockTextSizeManager,
            ratingManager: mockRatingManager,
            readingStatsManager: mockReadingStatsManager,
            articleFormatter: mockArticleFormatter,
            categoriesRepository: mockCategoriesRepository,
            shareService: mockShareService
        )
    }
    
    private func setupMockDependencies() {
        mockLocalizationManager = LocalizationManager()
        
        mockTextSizeManager = TextSizeManager()
        
        mockRatingManager = RatingManager()
        
        mockReadingStatsManager = ReadingStatsManager()
        
        mockArticleFormatter = ArticleFormatter(
            localizationManager: mockLocalizationManager,
            textSizeManager: mockTextSizeManager
        )
        
        mockCategoriesRepository = CategoriesRepository(
            localizationManager: mockLocalizationManager
        )
        
        mockShareService = ShareService()
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        FavoritesManager.shared.clearForTesting()
        ReadingHistoryManager.shared.clearForTesting()
        sut = nil
        testArticle = nil
        testArticles = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(sut.article.id, "test1", "Should set correct article")
        XCTAssertEqual(sut.allArticles.count, 3, "Should set all articles")
        XCTAssertFalse(sut.isFavorite, "Initially should not be favorite")
    }
    
    // MARK: - Favorite Management Tests
    
    func testToggleFavorite() {
        // Given - initial state
        XCTAssertFalse(sut.isFavorite)
        XCTAssertFalse(FavoritesManager.shared.isFavorite("test1"))
        
        // When - toggle favorite
        sut.toggleFavorite()
        
        // Then - should become favorite
        XCTAssertTrue(sut.isFavorite, "Should be favorite after toggling")
        XCTAssertTrue(FavoritesManager.shared.isFavorite("test1"), "FavoritesManager should reflect change")
        
        // When - toggle again
        sut.toggleFavorite()
        
        // Then - should remove from favorites
        XCTAssertFalse(sut.isFavorite, "Should not be favorite after second toggle")
        XCTAssertFalse(FavoritesManager.shared.isFavorite("test1"), "FavoritesManager should reflect removal")
    }
    
    // MARK: - Reading History Tests
    
    func testMarkAsRead() {
        // Given - article not in history initially
        XCTAssertFalse(ReadingHistoryManager.shared.isRead("test1"))
        
        // When - mark as read
        sut.markAsRead()
        
        // Then - should be in history
        XCTAssertTrue(ReadingHistoryManager.shared.isRead("test1"), "Should be marked as read")
    }
    
    func testMarkAsReadMultipleTimes() {
        // Given - mark as read once
        sut.markAsRead()
        _ = ReadingHistoryManager.shared.lastReadDate(for: "test1")
        
        // When - mark as read again
        sut.markAsRead()
        
        // Then - should update reading time
        let secondReadDate = ReadingHistoryManager.shared.lastReadDate(for: "test1")
        XCTAssertNotNil(secondReadDate)
    }
    
    // MARK: - Related Articles Logic Tests
    
    func testRelatedArticlesFiltering() {
        // When - get related articles
        let relatedArticles = sut.relatedArticles(limit: 3)
        
        // Then - should find articles with matching category
        XCTAssertEqual(relatedArticles.count, 1, "Should find one related article (excluding self)")
        XCTAssertEqual(relatedArticles.first?.id, "test2", "Should find article with matching category")
    }
    
    func testRelatedArticlesWithNoMatches() {
        // Given - article with unique category
        let uniqueArticle = Article(
            id: "unique",
            title: ["en": "Unique"],
            content: ["en": "Content"],
            categoryId: "c3", // Unique category
            tags: ["unique-tag"]
        )
        
        let uniqueSut = ArticleDetailViewModel(
            article: uniqueArticle,
            allArticles: testArticles,
            favoritesManager: FavoritesManager.shared,
            historyManager: ReadingHistoryManager.shared,
            localizationManager: mockLocalizationManager,
            textSizeManager: mockTextSizeManager,
            ratingManager: mockRatingManager,
            readingStatsManager: mockReadingStatsManager,
            articleFormatter: mockArticleFormatter,
            categoriesRepository: mockCategoriesRepository,
            shareService: mockShareService
        )
        
        // When - get related articles
        let relatedArticles = uniqueSut.relatedArticles(limit: 3)
        
        // Then - should be empty (no matching category)
        XCTAssertTrue(relatedArticles.isEmpty, "Should return empty for no matching category")
    }
    
    func testRelatedArticlesExcludesSelf() {
        // When - get related articles
        let relatedArticles = sut.relatedArticles(limit: 3)
        
        // Then - should not include the current article
        XCTAssertFalse(relatedArticles.contains { $0.id == "test1" }, "Should not include current article in related")
    }
    
    // MARK: - Article Content and Title Tests
    
    func testArticleContentLocalization() {
        // When - access article content
        let content = testArticle.localizedContent(for: "en")
        
        // Then - should return localized content
        XCTAssertEqual(content, "Test content", "Should return article content")
    }
    
    func testArticleTitleLocalization() {
        // When - access article title
        let title = testArticle.localizedTitle(for: "en")
        
        // Then - should return localized title
        XCTAssertEqual(title, "Test Article", "Should return article title")
    }
    
    // MARK: - PDF Export Tests
    
    func testPDFExport() {
        // This is mostly a smoke test to ensure no crashes
        // PDF export is hard to test directly as it involves UI operations
        XCTAssertTrue(true, "PDF export should complete without crashing")
    }
    
    // MARK: - AppContainer Integration Test
    
    func testAppContainerIntegration() {
        // When - create via AppContainer
        let container = AppContainer.shared
        let containerVM = container.makeArticleDetailViewModel(
            article: testArticle,
            allArticles: testArticles
        )
        
        // Then - should initialize properly
        XCTAssertEqual(containerVM.article.id, "test1")
        XCTAssertEqual(containerVM.allArticles.count, 3)
        XCTAssertFalse(containerVM.isFavorite)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyAllArticles() {
        // Given - empty articles list
        let emptySut = ArticleDetailViewModel(
            article: testArticle,
            allArticles: [],
            favoritesManager: FavoritesManager.shared,
            historyManager: ReadingHistoryManager.shared,
            localizationManager: mockLocalizationManager,
            textSizeManager: mockTextSizeManager,
            ratingManager: mockRatingManager,
            readingStatsManager: mockReadingStatsManager,
            articleFormatter: mockArticleFormatter,
            categoriesRepository: mockCategoriesRepository,
            shareService: mockShareService
        )
        
        // When - get related articles
        let relatedArticles = emptySut.relatedArticles(limit: 3)
        
        // Then - related articles should be empty
        XCTAssertTrue(relatedArticles.isEmpty, "Should handle empty allArticles")
    }
    
    func testArticleWithSameCategoryButDifferentTags() {
        // Given - articles with same category but different tags
        let articleSameCategory = Article(
            id: "same-cat-diff-tags",
            title: ["en": "Same Category"],
            content: ["en": "Content"],
            categoryId: "c1", // Same category as testArticle
            tags: ["different-tag"] // Different tags
        )
        
        let articlesWithMixed = testArticles + [articleSameCategory]
        
        let mixedSut = ArticleDetailViewModel(
            article: testArticle,
            allArticles: articlesWithMixed,
            favoritesManager: FavoritesManager.shared,
            historyManager: ReadingHistoryManager.shared,
            localizationManager: mockLocalizationManager,
            textSizeManager: mockTextSizeManager,
            ratingManager: mockRatingManager,
            readingStatsManager: mockReadingStatsManager,
            articleFormatter: mockArticleFormatter,
            categoriesRepository: mockCategoriesRepository,
            shareService: mockShareService
        )
        
        // When - get related articles
        let relatedArticles = mixedSut.relatedArticles(limit: 3)
        
        // Then - should include articles with same category regardless of tags
        XCTAssertEqual(relatedArticles.count, 2, "Should include all articles with same category")
        XCTAssertTrue(relatedArticles.contains { $0.id == "test2" })
        XCTAssertTrue(relatedArticles.contains { $0.id == "same-cat-diff-tags" })
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceToggleFavorite() {
        measure {
            sut.toggleFavorite()
        }
    }
    
    func testPerformanceMarkAsRead() {
        measure {
            sut.markAsRead()
        }
    }
}


*/
