import XCTest
@testable import InGermany

@MainActor
final class ArticlesRepositoryImplTests: XCTestCase {
    
    private var sut: ArticlesRepositoryImpl!
    private var articleFormatter: ArticleFormatter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        // 🔧 ИСПРАВЛЕНО: Передаем DataService в инициализатор
        sut = ArticlesRepositoryImpl(dataService: DataService.shared)
        articleFormatter = ArticleFormatter()
    }
    
    override func tearDown() {
        sut = nil
        articleFormatter = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_shouldCreateInstance() {
        // Then
        XCTAssertNotNil(sut, "Should create ArticlesRepositoryImpl instance")
    }
    
    // MARK: - Load Articles Tests
    
    func test_loadArticles_shouldReturnArticles() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        XCTAssertFalse(articles.isEmpty, "Should return articles from DataService")
        XCTAssertGreaterThan(articles.count, 0, "Should return at least one article")
    }
    
    func test_loadArticles_shouldReturnValidArticleStructure() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        XCTAssertFalse(articles.isEmpty, "Should return articles")
        
        let firstArticle = articles[0]
        XCTAssertFalse(firstArticle.id.isEmpty, "Article ID should not be empty")
        XCTAssertFalse(firstArticle.title.isEmpty, "Article title should not be empty")
        XCTAssertFalse(firstArticle.content.isEmpty, "Article content should not be empty")
        XCTAssertFalse(firstArticle.categoryId.isEmpty, "Article category ID should not be empty")
    }
    
    func test_loadArticles_shouldReturnArticlesWithValidProperties() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        for article in articles {
            // Test required properties
            XCTAssertFalse(article.id.isEmpty, "Article ID should not be empty")
            XCTAssertFalse(article.title.isEmpty, "Article title dictionary should not be empty")
            XCTAssertFalse(article.content.isEmpty, "Article content dictionary should not be empty")
            XCTAssertFalse(article.categoryId.isEmpty, "Article category ID should not be empty")
            
            // Test that at least one language is available
            let languages = ["en", "de", "ru"] // Основные языки приложения
            var hasLocalizedTitle = false
            var hasLocalizedContent = false
            
            for language in languages {
                if !article.localizedTitle(for: language).isEmpty {
                    hasLocalizedTitle = true
                }
                if !article.localizedContent(for: language).isEmpty {
                    hasLocalizedContent = true
                }
            }
            
            XCTAssertTrue(hasLocalizedTitle, "Should have localized title in at least one language")
            XCTAssertTrue(hasLocalizedContent, "Should have localized content in at least one language")
        }
    }
    
    // MARK: - Refresh Articles Tests
    
    func test_refreshArticles_shouldReturnArticles() async {
        // When
        let articles = await sut.refreshArticles()
        
        // Then
        XCTAssertFalse(articles.isEmpty, "Should return articles after refresh")
        XCTAssertGreaterThan(articles.count, 0, "Should return at least one article after refresh")
    }
    
    func test_refreshArticles_shouldReturnSameNumberOfArticlesAsLoad() async {
        // When
        let loadedArticles = await sut.loadArticles()
        let refreshedArticles = await sut.refreshArticles()
        
        // Then
        XCTAssertEqual(loadedArticles.count, refreshedArticles.count,
                      "Loaded and refreshed articles should have same count")
    }
    
    // MARK: - Get Last Source Tests
    
    func test_getLastSource_shouldReturnString() async {
        // When
        let source = await sut.getLastSource()
        
        // Then
        XCTAssertFalse(source.isEmpty, "Should return non-empty source string")
    }
    
    func test_getLastSource_shouldReturnValidSource() async {
        // When
        let source = await sut.getLastSource()
        
        // Then
        let validSources = ["local", "memory_cache", "network", "unknown"]
        XCTAssertTrue(validSources.contains(source) || source == "mock",
                     "Should return valid source value: \(source)")
    }
    
    // MARK: - Integration Tests
    
    func test_integration_allMethodsWorkTogether() async {
        // When - Test sequence of operations
        let initialArticles = await sut.loadArticles()
        let sourceAfterLoad = await sut.getLastSource()
        let refreshedArticles = await sut.refreshArticles()
        let sourceAfterRefresh = await sut.getLastSource()
        
        // Then
        XCTAssertEqual(initialArticles.count, refreshedArticles.count,
                      "Article count should be consistent between load and refresh")
        XCTAssertFalse(sourceAfterLoad.isEmpty, "Source should not be empty after load")
        XCTAssertFalse(sourceAfterRefresh.isEmpty, "Source should not be empty after refresh")
    }
    
    func test_integration_multipleLoadCalls() async {
        // When
        let articles1 = await sut.loadArticles()
        let articles2 = await sut.loadArticles()
        let articles3 = await sut.loadArticles()
        
        // Then
        XCTAssertEqual(articles1.count, articles2.count,
                      "Multiple load calls should return same count")
        XCTAssertEqual(articles2.count, articles3.count,
                      "All load calls should return consistent results")
    }
    
    // MARK: - Performance Tests
    
    func test_performance_loadArticles() {
        // When
        measure {
            let expectation = self.expectation(description: "Load articles performance")
            Task {
                _ = await self.sut.loadArticles()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func test_performance_refreshArticles() {
        // When
        measure {
            let expectation = self.expectation(description: "Refresh articles performance")
            Task {
                _ = await self.sut.refreshArticles()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func test_performance_multipleOperations() {
        // When
        measure {
            let expectation = self.expectation(description: "Multiple operations performance")
            Task {
                _ = await self.sut.loadArticles()
                _ = await self.sut.getLastSource()
                _ = await self.sut.refreshArticles()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Concurrency Tests
    
    func test_concurrency_simultaneousLoadCalls() async {
        // When - Multiple concurrent calls
        async let load1 = sut.loadArticles()
        async let load2 = sut.loadArticles()
        async let load3 = sut.loadArticles()
        
        let results = await [load1, load2, load3]
        
        // Then
        XCTAssertEqual(results.count, 3, "Should complete all concurrent calls")
        for result in results {
            XCTAssertFalse(result.isEmpty, "Each call should return articles")
            XCTAssertGreaterThan(result.count, 0, "Each call should return at least one article")
        }
    }
    
    func test_concurrency_mixedOperations() async {
        // When - Mixed concurrent operations
        async let load = sut.loadArticles()
        async let refresh = sut.refreshArticles()
        async let source = sut.getLastSource()
        
        let (articles, refreshedArticles, sourceValue) = await (load, refresh, source)
        
        // Then
        XCTAssertEqual(articles.count, refreshedArticles.count,
                      "Load and refresh should return same count")
        XCTAssertFalse(sourceValue.isEmpty, "Should return source value")
    }
    
    // MARK: - Data Consistency Tests
    
    func test_dataConsistency_articleStructure() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        for article in articles {
            XCTAssertFalse(article.id.isEmpty, "Article ID should not be empty")
            XCTAssertFalse(article.title.isEmpty, "Article title should not be empty")
            XCTAssertFalse(article.content.isEmpty, "Article content should not be empty")
            XCTAssertFalse(article.categoryId.isEmpty, "Article category ID should not be empty")
            
            // Test that article has valid UUID format
            XCTAssertTrue(article.id.count >= 10, "Article ID should be reasonable length")
        }
    }
    
    func test_dataConsistency_acrossMultipleRefreshes() async {
        // When
        let articles1 = await sut.refreshArticles()
        let articles2 = await sut.refreshArticles()
        let articles3 = await sut.refreshArticles()
        
        // Then
        XCTAssertEqual(articles1.count, articles2.count,
                      "Article count should be consistent across refreshes")
        XCTAssertEqual(articles2.count, articles3.count,
                      "Article count should remain stable")
    }
    
    // MARK: - Edge Cases Tests
    
    func test_edgeCase_rapidSuccessionCalls() async {
        // When - Rapid calls in succession
        var articles: [Article] = []
        var sources: [String] = []
        
        for i in 0..<10 {
            if i % 2 == 0 {
                let result = await sut.loadArticles()
                articles.append(contentsOf: result)
            } else {
                let source = await sut.getLastSource()
                sources.append(source)
            }
        }
        
        // Then
        XCTAssertGreaterThan(articles.count, 0, "Should handle rapid succession calls")
        XCTAssertEqual(sources.count, 5, "Should handle mixed rapid calls")
    }
    
    func test_edgeCase_alternatingLoadRefresh() async {
        // When - Alternating between load and refresh
        var results: [[Article]] = []
        
        for i in 0..<5 {
            let articles = i % 2 == 0
                ? await sut.loadArticles()
                : await sut.refreshArticles()
            results.append(articles)
        }
        
        // Then
        XCTAssertEqual(results.count, 5, "Should complete all alternating operations")
        for result in results {
            XCTAssertFalse(result.isEmpty, "Each operation should return articles")
            XCTAssertGreaterThan(result.count, 0, "Each operation should return at least one article")
        }
    }
    
    // MARK: - Article Content Tests
    
    func test_articleContent_shouldHaveMultipleLanguages() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        for article in articles {
            // Test major languages
            let languages = ["en", "de", "ru"]
            
            for language in languages {
                let title = article.localizedTitle(for: language)
                let content = article.localizedContent(for: language)
                
                // At least one major language should have content
                if !title.isEmpty {
                    XCTAssertGreaterThan(title.count, 5, "Title should have reasonable length for language: \(language)")
                }
                if !content.isEmpty {
                    XCTAssertGreaterThan(content.count, 10, "Content should have reasonable length for language: \(language)")
                }
            }
            
            // At least one language should have content
            let hasTitle = languages.contains { !article.localizedTitle(for: $0).isEmpty }
            let hasContent = languages.contains { !article.localizedContent(for: $0).isEmpty }
            
            XCTAssertTrue(hasTitle, "Article should have title in at least one major language")
            XCTAssertTrue(hasContent, "Article should have content in at least one major language")
        }
    }
    
    func test_articleMetadata_shouldHaveValidDates() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        for article in articles {
            // Используем ArticleFormatter для форматирования дат
            let createdDate = articleFormatter.formattedCreatedDate(article, for: "ru")
            let updatedDate = articleFormatter.formattedUpdatedDate(article, for: "ru")
            
            XCTAssertFalse(createdDate.isEmpty, "Article should have formatted created date")
            XCTAssertFalse(updatedDate.isEmpty, "Article should have formatted updated date")
        }
    }
    
    // MARK: - Article Tags Tests
    
    func test_articles_shouldHaveValidTags() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then
        for article in articles {
            // Tags should be an array (can be empty)
            XCTAssertNotNil(article.tags, "Article tags should not be nil")
            
            // If tags exist, they should not be empty strings
            for tag in article.tags {
                XCTAssertFalse(tag.isEmpty, "Tag should not be empty string")
            }
        }
    }
    
    // MARK: - Article Formatter Integration Tests
    
    func test_articleFormatter_integration() async {
        // When
        let articles = await sut.loadArticles()
        
        // Then - Test that articles work with ArticleFormatter
        for article in articles {
            let wordCount = articleFormatter.wordCount(article, for: "ru")
            let readingTime = articleFormatter.readingTime(article, for: "ru")
            let formattedReadingTime = articleFormatter.formatReadingTime(readingTime, language: "ru")
            
            XCTAssertGreaterThanOrEqual(wordCount, 0, "Word count should be non-negative")
            XCTAssertGreaterThanOrEqual(readingTime, 0, "Reading time should be non-negative")
            XCTAssertFalse(formattedReadingTime.isEmpty, "Formatted reading time should not be empty")
        }
    }
}
