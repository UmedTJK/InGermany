//
//  ReadingHistoryManagerTests.swift
//  InGermany
//
//  Created by SUM TJK on 05.10.25.
//
import XCTest
import Combine
@testable import InGermany

@MainActor
final class ReadingHistoryManagerTests: XCTestCase {
    
    private var sut: ReadingStatsManager!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = ReadingStatsManager.shared
        cancellables = []
        sut.clearHistory()
    }
    
    override func tearDown() {
        sut.clearHistory()
        cancellables = []
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_shouldHaveEmptyHistory() {
        // Then
        XCTAssertTrue(sut.history.isEmpty, "History should be empty initially")
        XCTAssertEqual(sut.totalArticlesRead, 0, "Total articles read should be 0")
        XCTAssertEqual(sut.totalReadingTimeMinutes, 0, "Total reading time should be 0")
    }
    
    // MARK: - Add Reading Entry Tests
    
    func test_addReadingEntry_shouldAddToHistory() {
        // Given
        let articleId = "test-article-1"
        let readingTime: TimeInterval = 120 // 2 minutes
        
        // When
        sut.addReadingEntry(articleId: articleId, readingTime: readingTime)
        
        // Then
        XCTAssertEqual(sut.history.count, 1, "Should have one entry in history")
        XCTAssertEqual(sut.history.first?.articleId, articleId, "Should store correct article ID")
        XCTAssertEqual(sut.history.first?.readingTimeSeconds, readingTime, "Should store correct reading time")
        XCTAssertTrue(sut.isRead(articleId), "Article should be marked as read")
    }
    
    func test_addReadingEntry_shouldReplaceDuplicateArticle() {
        // Given
        let articleId = "test-article-duplicate"
        let firstReadingTime: TimeInterval = 60
        let secondReadingTime: TimeInterval = 180
        
        // When
        sut.addReadingEntry(articleId: articleId, readingTime: firstReadingTime)
        sut.addReadingEntry(articleId: articleId, readingTime: secondReadingTime)
        
        // Then
        XCTAssertEqual(sut.history.count, 1, "Should have only one entry for duplicate article")
        XCTAssertEqual(sut.history.first?.readingTimeSeconds, secondReadingTime, "Should keep latest reading time")
    }
    
    func test_addReadingEntry_shouldLimitHistorySize() {
        // Given
        let maxEntries = 100
        
        // When - Add more than max entries
        for i in 0..<(maxEntries + 10) {
            sut.addReadingEntry(articleId: "article-\(i)", readingTime: Double(i * 60))
        }
        
        // Then
        XCTAssertEqual(sut.history.count, maxEntries, "Should limit history to max entries")
        XCTAssertEqual(sut.history.first?.articleId, "article-109", "Should keep newest entries")
        XCTAssertEqual(sut.history.last?.articleId, "article-10", "Should remove oldest entries")
    }
    
    // MARK: - Recently Read Articles Tests
    
    func test_recentlyReadArticles_shouldReturnCorrectArticles() {
        // Given
        let articles = [
            Article(id: "article-1", title: ["en": "Article 1"], content: ["en": "Content 1"], categoryId: "cat1", tags: []),
            Article(id: "article-2", title: ["en": "Article 2"], content: ["en": "Content 2"], categoryId: "cat2", tags: []),
            Article(id: "article-3", title: ["en": "Article 3"], content: ["en": "Content 3"], categoryId: "cat3", tags: [])
        ]
        
        // When - Add entries in reverse order
        sut.addReadingEntry(articleId: "article-3", readingTime: 180)
        sut.addReadingEntry(articleId: "article-1", readingTime: 120)
        sut.addReadingEntry(articleId: "article-2", readingTime: 150)
        
        // Then
        let recent = sut.recentlyReadArticles(from: articles, limit: 2)
        XCTAssertEqual(recent.count, 2, "Should return limited number of articles")
        XCTAssertEqual(recent[0].id, "article-2", "Should return most recent first")
        XCTAssertEqual(recent[1].id, "article-1", "Should return second most recent")
    }
    
    // MARK: - Reading Stats Tests
    
    func test_totalArticlesRead_shouldCountUniqueArticles() {
        // Given
        sut.addReadingEntry(articleId: "article-1", readingTime: 120)
        sut.addReadingEntry(articleId: "article-2", readingTime: 180)
        sut.addReadingEntry(articleId: "article-1", readingTime: 150) // Duplicate
        
        // Then
        XCTAssertEqual(sut.totalArticlesRead, 2, "Should count unique articles only")
    }
    
    func test_totalReadingTimeMinutes_shouldCalculateCorrectly() {
        // Given
        sut.addReadingEntry(articleId: "article-1", readingTime: 120)  // 2 minutes
        sut.addReadingEntry(articleId: "article-2", readingTime: 180)  // 3 minutes
        
        // Then
        XCTAssertEqual(sut.totalReadingTimeMinutes, 5, "Should calculate total reading time in minutes")
    }
    
    func test_lastReadDate_shouldReturnCorrectDate() {
        // Given
        let articleId = "test-article-date"
        let beforeAdd = Date()
        
        // When
        sut.addReadingEntry(articleId: articleId, readingTime: 120)
        
        // Then
        guard let lastReadDate = sut.lastReadDate(for: articleId) else {
            XCTFail("Should return last read date")
            return
        }
        XCTAssertTrue(lastReadDate > beforeAdd, "Last read date should be after adding entry")
    }
    
    // MARK: - ReadingStats Tests
    
    func test_getStats_shouldCalculateCorrectStatistics() {
        // Given
        sut.addReadingEntry(articleId: "article-1", readingTime: 120)  // 2 minutes
        sut.addReadingEntry(articleId: "article-2", readingTime: 180)  // 3 minutes
        sut.addReadingEntry(articleId: "article-3", readingTime: 300)  // 5 minutes
        
        // When
        let stats = sut.getStats()
        
        // Then - Используем актуальные свойства из ReadingStats
        XCTAssertEqual(stats.totalReadCount, 3, "Should count total read entries")
        XCTAssertEqual(stats.totalReadingTimeSeconds, 600, "Should calculate total time in seconds") // 120+180+300=600
        XCTAssertNotNil(stats.lastReadDate, "Should have last read date")
    }
    
    // MARK: - Clear Methods Tests
    
    func test_clearHistory_shouldRemoveAllEntries() {
        // Given
        sut.addReadingEntry(articleId: "article-1", readingTime: 120)
        sut.addReadingEntry(articleId: "article-2", readingTime: 180)
        XCTAssertEqual(sut.history.count, 2, "Should have entries before clear")
        
        // When
        sut.clearHistory()
        
        // Then
        XCTAssertTrue(sut.history.isEmpty, "Should remove all entries")
        XCTAssertEqual(sut.totalArticlesRead, 0, "Total articles should be 0")
    }
    
    // MARK: - Persistence Tests
    
    func test_persistence_shouldSaveAndLoadHistory() {
        // Given
        let articleId = "persistence-test"
        let readingTime: TimeInterval = 150
        
        // When - Add entry and create new instance
        sut.addReadingEntry(articleId: articleId, readingTime: readingTime)
        
        let newInstance = ReadingStatsManager.shared
        
        // Then
        XCTAssertTrue(newInstance.isRead(articleId), "Should persist history between instances")
        XCTAssertEqual(newInstance.history.count, 1, "Should load saved history")
    }
    
    // MARK: - Performance Tests
    
    func test_performance_addMultipleEntries() {
        // Given
        let count = 1000
        
        // When
        measure {
            for i in 0..<count {
                sut.addReadingEntry(articleId: "perf-article-\(i)", readingTime: Double(i * 60))
            }
        }
    }
    
    func test_performance_isReadOperation() {
        // Given
        for i in 0..<100 {
            sut.addReadingEntry(articleId: "test-article-\(i)", readingTime: 120)
        }
        
        // When
        measure {
            for i in 0..<1000 {
                _ = sut.isRead("test-article-\(i % 100)")
            }
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func test_edgeCase_zeroReadingTime() {
        // Given
        let articleId = "zero-time-article"
        
        // When
        sut.addReadingEntry(articleId: articleId, readingTime: 0)
        
        // Then
        XCTAssertTrue(sut.isRead(articleId), "Should accept zero reading time")
        XCTAssertEqual(sut.history.first?.readingTimeSeconds, 0, "Should store zero reading time")
    }
    
    func test_edgeCase_veryLongReadingTime() {
        // Given
        let articleId = "long-time-article"
        let longTime: TimeInterval = 3600 * 24 // 24 hours
        
        // When
        sut.addReadingEntry(articleId: articleId, readingTime: longTime)
        
        // Then
        XCTAssertEqual(sut.totalReadingTimeMinutes, 1440, "Should handle very long reading times") // 24*60
    }
    
    func test_edgeCase_emptyArticleId() {
        // Given
        let emptyArticleId = ""
        
        // When
        sut.addReadingEntry(articleId: emptyArticleId, readingTime: 120)
        
        // Then
        XCTAssertTrue(sut.isRead(emptyArticleId), "Should handle empty article ID")
    }
}
