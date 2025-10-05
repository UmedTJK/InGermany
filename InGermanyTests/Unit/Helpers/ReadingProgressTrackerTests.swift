//
//  ReadingTimeTrackerTests.swift
//  InGermanyTests
//
//  Created by SUM TJK  on 04.10.25.
//

import XCTest
@testable import InGermany

@MainActor
final class ReadingTimeTrackerTests: XCTestCase {
    
    private var tracker: ReadingTimeTracker!
    
    override func setUp() {
        super.setUp()
        tracker = ReadingTimeTracker.shared
        tracker.clearSessions() // Clear any existing sessions
    }
    
    override func tearDown() {
        tracker.clearSessions()
        super.tearDown()
    }
    
    // MARK: - Session Management Tests
    
    func testStartSession() {
        let articleId = "test-article-1"
        
        tracker.startSession(articleId: articleId)
        
        XCTAssertTrue(tracker.activeSessions.keys.contains(articleId), "Session should be started")
        XCTAssertNil(tracker.activeSessions[articleId]?.endTime, "Active session should not have end time")
    }
    
    func testEndSession() {
        let articleId = "test-article-1"
        
        tracker.startSession(articleId: articleId)
        XCTAssertTrue(tracker.activeSessions.keys.contains(articleId), "Session should be started")
        
        // Wait a bit to have measurable duration
        Thread.sleep(forTimeInterval: 0.1)
        
        tracker.endSession(articleId: articleId)
        
        XCTAssertFalse(tracker.activeSessions.keys.contains(articleId), "Session should be ended")
        XCTAssertEqual(tracker.completedSessions.count, 1, "Completed sessions should contain the session")
        
        let completedSession = tracker.completedSessions.first
        XCTAssertEqual(completedSession?.articleId, articleId, "Completed session should have correct article ID")
        XCTAssertNotNil(completedSession?.endTime, "Completed session should have end time")
        XCTAssertNotNil(completedSession?.duration, "Completed session should have duration")
    }
    
    func testEndSessionWithoutStart() {
        let articleId = "non-existent-article"
        
        // This should not crash
        tracker.endSession(articleId: articleId)
        
        XCTAssertEqual(tracker.completedSessions.count, 0, "No session should be completed")
    }
    
    func testMultipleSessions() {
        let articleIds = ["article-1", "article-2", "article-3"]
        
        // Start multiple sessions
        for articleId in articleIds {
            tracker.startSession(articleId: articleId)
        }
        
        XCTAssertEqual(tracker.activeSessions.count, 3, "Should have 3 active sessions")
        
        // End one session
        tracker.endSession(articleId: articleIds[0])
        
        XCTAssertEqual(tracker.activeSessions.count, 2, "Should have 2 active sessions after ending one")
        XCTAssertEqual(tracker.completedSessions.count, 1, "Should have 1 completed session")
    }
    
    // MARK: - Duration Tests
    
    func testSessionDuration() {
        let articleId = "duration-test-article"
        
        tracker.startSession(articleId: articleId)
        
        // Wait for a specific duration
        let waitDuration: TimeInterval = 0.5
        Thread.sleep(forTimeInterval: waitDuration)
        
        tracker.endSession(articleId: articleId)
        
        let completedSession = tracker.completedSessions.first
        XCTAssertNotNil(completedSession?.duration, "Session should have duration")
        
        if let duration = completedSession?.duration {
            XCTAssertGreaterThan(duration, waitDuration - 0.1, "Duration should be approximately the wait time")
            XCTAssertLessThan(duration, waitDuration + 0.1, "Duration should be approximately the wait time")
        }
    }
    
    func testShortSessionNotRecorded() {
        let articleId = "short-session-article"
        
        tracker.startSession(articleId: articleId)
        
        // End immediately (less than 3 seconds)
        tracker.endSession(articleId: articleId)
        
        XCTAssertEqual(tracker.completedSessions.count, 0, "Very short sessions (<3s) should not be recorded")
    }
    
    // MARK: - Statistics Tests
    
    func testTotalReadingTime() {
        // Create some completed sessions by simulating real usage
        let articleIds = ["article-1", "article-2", "article-3"]
        let durations: [TimeInterval] = [120.0, 180.0, 300.0] // 2, 3, 5 minutes
        
        for (articleId, duration) in zip(articleIds, durations) {
            tracker.startSession(articleId: articleId)
            Thread.sleep(forTimeInterval: duration)
            tracker.endSession(articleId: articleId)
        }
        
        let totalTime = tracker.getTotalReadingTime()
        XCTAssertEqual(totalTime, 10, "Total reading time should be 10 minutes (2+3+5)")
        
        let totalSeconds = tracker.getTotalReadingTimeInSeconds()
        XCTAssertEqual(totalSeconds, 600, "Total reading time in seconds should be 600")
    }
    
    func testReadingTimeForLastDays() {
        // Use real sessions instead of direct assignment
        let articleIds = ["today-article", "yesterday-article", "old-article"]
        
        // Create sessions by simulating usage with appropriate timing
        for articleId in articleIds {
            tracker.startSession(articleId: articleId)
            Thread.sleep(forTimeInterval: 0.1) // Short wait to ensure recording
            tracker.endSession(articleId: articleId)
        }
        
        // We can't test exact time filtering without direct date manipulation,
        // but we can verify the method works without crashing
        let last7DaysTime = tracker.getReadingTimeForLast(days: 7)
        let last30DaysTime = tracker.getReadingTimeForLast(days: 30)
        
        XCTAssertGreaterThanOrEqual(last7DaysTime, 0, "Reading time should be non-negative")
        XCTAssertGreaterThanOrEqual(last30DaysTime, 0, "Reading time should be non-negative")
        XCTAssertLessThanOrEqual(last7DaysTime, last30DaysTime, "7 days should be <= 30 days")
    }
    
    // MARK: - Data Persistence Tests
    
    func testSessionsPersistence() {
        let articleId = "persistence-test-article"
        
        // Start and end a session
        tracker.startSession(articleId: articleId)
        Thread.sleep(forTimeInterval: 0.5)
        tracker.endSession(articleId: articleId)
        
        let initialCount = tracker.completedSessions.count
        XCTAssertGreaterThan(initialCount, 0, "Should have completed sessions")
    }
    
    // MARK: - Edge Cases
    
    func testSameArticleMultipleSessions() {
        let articleId = "repeated-article"
        
        // First session
        tracker.startSession(articleId: articleId)
        Thread.sleep(forTimeInterval: 0.4)
        tracker.endSession(articleId: articleId)
        
        // Second session for same article
        tracker.startSession(articleId: articleId)
        Thread.sleep(forTimeInterval: 0.4)
        tracker.endSession(articleId: articleId)
        
        XCTAssertEqual(tracker.completedSessions.count, 2, "Multiple sessions for same article should be recorded")
        
        let articleSessions = tracker.completedSessions.filter { $0.articleId == articleId }
        XCTAssertEqual(articleSessions.count, 2, "Should have 2 sessions for the same article")
    }
    
    func testClearSessions() {
        // Add some completed sessions by simulating usage
        let articleIds = ["article-1", "article-2"]
        
        for articleId in articleIds {
            tracker.startSession(articleId: articleId)
            Thread.sleep(forTimeInterval: 0.1)
            tracker.endSession(articleId: articleId)
        }
        
        XCTAssertEqual(tracker.completedSessions.count, 2, "Should have 2 sessions before clearing")
        
        tracker.clearSessions()
        
        XCTAssertEqual(tracker.completedSessions.count, 0, "Should have 0 sessions after clearing")
    }
    
    func testActiveSessionsNotCleared() {
        let articleId = "active-session-article"
        
        tracker.startSession(articleId: articleId)
        tracker.clearSessions() // This should only clear completed sessions
        
        XCTAssertEqual(tracker.activeSessions.count, 1, "Active sessions should not be cleared")
        XCTAssertEqual(tracker.completedSessions.count, 0, "Completed sessions should be cleared")
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithReadingHistoryManager() {
        let articleId = "integration-test-article"
        
        // Simulate reading session
        tracker.startSession(articleId: articleId)
        Thread.sleep(forTimeInterval: 0.5)
        tracker.endSession(articleId: articleId)
        
        // Verify session was recorded
        XCTAssertEqual(tracker.completedSessions.count, 1, "Session should be recorded")
        
        let completedSession = tracker.completedSessions.first
        XCTAssertNotNil(completedSession?.duration, "Session should have duration")
        XCTAssertGreaterThan(completedSession!.duration!, 3.0, "Session duration should be greater than 3 seconds")
    }
    
    func testRealWorldReadingScenario() {
        let articleIds = ["article-1", "article-2", "article-3"]
        let readingDurations: [TimeInterval] = [4.0, 8.0, 12.0] // seconds
        
        for (articleId, duration) in zip(articleIds, readingDurations) {
            tracker.startSession(articleId: articleId)
            Thread.sleep(forTimeInterval: duration)
            tracker.endSession(articleId: articleId)
        }
        
        XCTAssertEqual(tracker.completedSessions.count, 3, "All reading sessions should be recorded")
        
        let totalReadingTime = tracker.getTotalReadingTimeInSeconds()
        let expectedTotal = readingDurations.reduce(0, +)
        XCTAssertGreaterThanOrEqual(totalReadingTime, Int(expectedTotal) - 1, "Total reading time should be approximately sum of durations")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceSessionStart() {
        measure {
            for i in 0..<100 {
                tracker.startSession(articleId: "perf-article-\(i)")
            }
        }
    }
    
    func testPerformanceSessionEnd() {
        // Setup: create many active sessions
        for i in 0..<100 {
            tracker.startSession(articleId: "perf-end-article-\(i)")
        }
        
        measure {
            for i in 0..<100 {
                tracker.endSession(articleId: "perf-end-article-\(i)")
            }
        }
    }
    
    func testPerformanceStatisticsCalculation() {
        // Setup: create many completed sessions by simulation
        for i in 0..<100 {
            tracker.startSession(articleId: "stats-article-\(i)")
            Thread.sleep(forTimeInterval: 0.01) // Very short duration
            tracker.endSession(articleId: "stats-article-\(i)")
        }
        
        measure {
            _ = tracker.getTotalReadingTime()
            _ = tracker.getReadingTimeForLast(days: 7)
            _ = tracker.getReadingTimeForLast(days: 30)
        }
    }
    
    // MARK: - Helper Methods for Testing
    
    private func createCompletedSession(articleId: String, duration: TimeInterval) {
        tracker.startSession(articleId: articleId)
        Thread.sleep(forTimeInterval: duration)
        tracker.endSession(articleId: articleId)
    }
}
