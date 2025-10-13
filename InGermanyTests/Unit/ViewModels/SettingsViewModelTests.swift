//
//  SettingsViewModelTests.swift
//  InGermanyTests
//
//  Extended and documented by AI Assistant 07.10.2025
//

import XCTest
@testable import InGermany

/// Tests for `SettingsViewModel` covering initialization, language management, history management, statistics, integration with AppContainer and UserDefaults.
@MainActor
final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!
    var mockLocalizationManager: LocalizationManager!
    var mockStatsManager: MockReadingStatsManager!
    
    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        // Clean up before each test to ensure isolation
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        
        // Create mock dependencies
        mockLocalizationManager = LocalizationManager.shared
        mockStatsManager = MockReadingStatsManager()
        
        // Initialize ViewModel with correct dependencies
        sut = SettingsViewModel(
            localizationManager: mockLocalizationManager,
            statsManager: mockStatsManager
        )
    }
    
    override func tearDown() async throws {
        // Clean up after each test to ensure isolation
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        sut = nil
        mockLocalizationManager = nil
        mockStatsManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateDefaults() {
        /// After cleanup, default language should be Russian and history flag false
        XCTAssertEqual(sut.selectedLanguage, "ru", "Default language should be Russian after cleanup")
        XCTAssertFalse(sut.isHistoryCleared, "Initially history should not be cleared")
    }
    
    // MARK: - Language Management Tests
    
    func testChangeLanguagePersists() {
        XCTAssertEqual(sut.selectedLanguage, "ru")
        sut.selectedLanguage = "en" // Direct assignment instead of changeLanguage method
        XCTAssertEqual(sut.selectedLanguage, "en")
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en")
    }
    
    func testChangeToUnsupportedLanguageAllowed() {
        sut.selectedLanguage = "fr"
        XCTAssertEqual(sut.selectedLanguage, "fr")
    }
    
    func testMultipleLanguageChangesSequence() {
        sut.selectedLanguage = "en"
        XCTAssertEqual(sut.selectedLanguage, "en")
        sut.selectedLanguage = "de"
        XCTAssertEqual(sut.selectedLanguage, "de")
        sut.selectedLanguage = "ru"
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
    
    func testEmptyLanguageChangeAllowed() {
        sut.selectedLanguage = ""
        XCTAssertEqual(sut.selectedLanguage, "")
    }
    
    func testVeryLongLanguageCodeHandled() {
        let longCode = String(repeating: "a", count: 100)
        sut.selectedLanguage = longCode
        XCTAssertEqual(sut.selectedLanguage, longCode)
    }
    
    // MARK: - History Management Tests
    
    func testClearHistoryRemovesEntriesAndSetsFlag() {
        // Setup mock
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120)
        ]
        
        XCTAssertFalse(mockStatsManager.history.isEmpty)
        sut.clearHistory()
        XCTAssertTrue(mockStatsManager.history.isEmpty)
        XCTAssertTrue(sut.isHistoryCleared)
    }
    
    func testClearHistoryWithEmptyHistoryStillSetsFlag() {
        XCTAssertTrue(mockStatsManager.history.isEmpty)
        sut.clearHistory()
        XCTAssertTrue(mockStatsManager.history.isEmpty)
        XCTAssertTrue(sut.isHistoryCleared)
    }
    
    func testHistoryClearedFlagResetsOnNewInstance() {
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120)
        ]
        
        sut.clearHistory()
        XCTAssertTrue(sut.isHistoryCleared)
        
        let newViewModel = SettingsViewModel(
            localizationManager: mockLocalizationManager,
            statsManager: mockStatsManager
        )
        XCTAssertFalse(newViewModel.isHistoryCleared)
    }
    
    // MARK: - Statistics Tests
    
    func testTotalArticlesReadWithHistory() {
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120),
            ReadingHistoryEntry(articleId: "test2", readingTimeSeconds: 180)
        ]
        
        XCTAssertEqual(sut.totalArticlesRead, 2)
    }
    
    func testTotalArticlesReadWithEmptyHistory() {
        XCTAssertEqual(sut.totalArticlesRead, 0)
    }
    
    func testStatsConsistencyUniqueArticles() {
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 60),
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120) // Duplicate
        ]
        
        XCTAssertEqual(sut.totalArticlesRead, 1, "Should count unique articles only")
    }
    
    func testFormattedReadingTime() {
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120), // 2 minutes
            ReadingHistoryEntry(articleId: "test2", readingTimeSeconds: 180)  // 3 minutes
        ]
        
        let totalTime = sut.formattedTotalReadingTime
        let averageTime = sut.formattedAverageReadingTime
        
        // These should return formatted strings, not be empty
        XCTAssertFalse(totalTime.isEmpty)
        XCTAssertFalse(averageTime.isEmpty)
    }
    
    // MARK: - UserDefaults Integration Test
    
    func testLanguagePersistenceAfterChange() {
        sut.selectedLanguage = "en"
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en")
    }
    
    // MARK: - Isolation Test
    
    func testIsolatedUserDefaultsStartsWithDefaults() {
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
    
    // MARK: - Reset Tests
    
    func testResetToDefaults() {
        // Set some custom values
        sut.selectedLanguage = "en"
        sut.isDarkMode = true
        sut.relativeDates = false
        sut.selectedCardStyle = .fullWidth // Используем существующий случай
        
        // Add some history
        mockStatsManager.mockHistory = [
            ReadingHistoryEntry(articleId: "test1", readingTimeSeconds: 120)
        ]
        
        // Reset to defaults
        sut.resetToDefaults()
        
        // Check if reset to defaults
        XCTAssertEqual(sut.selectedLanguage, "ru")
        XCTAssertFalse(sut.isDarkMode)
        XCTAssertTrue(sut.relativeDates)
        XCTAssertEqual(sut.selectedCardStyle, .allCorners) // Первый случай в enum
        
        // History should be cleared
        XCTAssertTrue(mockStatsManager.history.isEmpty)
        XCTAssertTrue(sut.isHistoryCleared)
    }
}

// MARK: - Mock ReadingStatsManager

@MainActor
class MockReadingStatsManager: ReadingStatsManaging {
    var mockHistory: [ReadingHistoryEntry] = []
    var mockProgress: [String: CGFloat] = [:]
    var mockActiveSessions: [String: ReadingSession] = [:]
    var mockCompletedSessions: [ReadingSession] = []
    
    var history: [ReadingHistoryEntry] {
        return mockHistory
    }
    
    var totalArticlesRead: Int {
        return Set(mockHistory.map { $0.articleId }).count
    }
    
    var totalReadingTimeMinutes: Int {
        let totalSeconds = mockHistory.reduce(0) { $0 + $1.readingTimeSeconds }
        return Int(totalSeconds / 60)
    }
    
    // MARK: - Progress Methods
    func updateProgress(for articleID: String, value: CGFloat) {
        mockProgress[articleID] = value
    }
    
    func progressForArticle(_ articleID: String) -> CGFloat {
        return mockProgress[articleID] ?? 0
    }
    
    func resetProgress(for articleID: String) {
        mockProgress[articleID] = 0
    }
    
    // MARK: - Session Methods
    func startSession(articleId: String) {
        let session = ReadingSession(articleId: articleId, startTime: Date())
        mockActiveSessions[articleId] = session
    }
    
    func endSession(articleId: String) {
        guard var session = mockActiveSessions[articleId] else { return }
        session.endTime = Date()
        mockActiveSessions.removeValue(forKey: articleId)
        
        if let duration = session.duration, duration > 3 {
            mockCompletedSessions.append(session)
            addReadingEntry(articleId: articleId, readingTime: duration)
        }
    }
    
    func currentReadingTime(for articleId: String) -> TimeInterval {
        guard let session = mockActiveSessions[articleId] else { return 0 }
        return Date().timeIntervalSince(session.startTime)
    }
    
    // MARK: - History Methods
    func addReadingEntry(articleId: String, readingTime: TimeInterval) {
        mockHistory.removeAll { $0.articleId == articleId }
        let entry = ReadingHistoryEntry(articleId: articleId, readingTimeSeconds: readingTime)
        mockHistory.insert(entry, at: 0)
    }
    
    func clearHistory() {
        mockHistory.removeAll()
        mockProgress.removeAll()
        mockCompletedSessions.removeAll()
    }
    
    func isRead(_ articleId: String) -> Bool {
        return mockHistory.contains { $0.articleId == articleId }
    }
    
    func lastReadDate(for articleId: String) -> Date? {
        return mockHistory.first { $0.articleId == articleId }?.readAt
    }
    
    func recentlyReadArticles(from allArticles: [Article], limit: Int) -> [Article] {
        let recentIds = Array(mockHistory.prefix(limit).map { $0.articleId })
        return recentIds.compactMap { id in allArticles.first { $0.id == id } }
    }
    
    // MARK: - Helper Methods
    func formatReadingTime(_ minutes: Int, language: String) -> String {
        return "\(minutes) min"
    }
    
    func estimateReadingTime(for text: String, language: String) -> Int {
        return max(1, text.count / 200) // Simple mock, minimum 1 minute
    }
    
    func progressStatus(for progress: CGFloat, language: String) -> String {
        switch progress {
        case 0..<0.1: return "Начало"
        case 0.1..<0.7: return "В процессе"
        case 0.7..<0.99: return "Почти готово"
        default: return "Готово"
        }
    }
    
    func getStats() -> ReadingStats {
        return ReadingStats(from: mockHistory)
    }
}
