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
    
    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        // Clean up before each test to ensure isolation
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        ReadingHistoryManager.shared.clearForTesting()
        // Initialize ViewModel
        sut = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
    }
    
    override func tearDown() async throws {
        // Clean up after each test to ensure isolation
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        ReadingHistoryManager.shared.clearForTesting()
        sut = nil
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
        sut.changeLanguage(to: "en")
        XCTAssertEqual(sut.selectedLanguage, "en")
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en")
    }
    
    func testChangeToUnsupportedLanguageAllowed() {
        sut.changeLanguage(to: "fr")
        XCTAssertEqual(sut.selectedLanguage, "fr")
    }
    
    func testMultipleLanguageChangesSequence() {
        sut.changeLanguage(to: "en")
        XCTAssertEqual(sut.selectedLanguage, "en")
        sut.changeLanguage(to: "de")
        XCTAssertEqual(sut.selectedLanguage, "de")
        sut.changeLanguage(to: "ru")
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
    
    func testEmptyLanguageChangeAllowed() {
        sut.changeLanguage(to: "")
        XCTAssertEqual(sut.selectedLanguage, "")
    }
    
    func testVeryLongLanguageCodeHandled() {
        let longCode = String(repeating: "a", count: 100)
        sut.changeLanguage(to: longCode)
        XCTAssertEqual(sut.selectedLanguage, longCode)
    }
    
    // MARK: - History Management Tests
    
    func testClearHistoryRemovesEntriesAndSetsFlag() {
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        XCTAssertFalse(ReadingHistoryManager.shared.history.isEmpty)
        sut.clearHistory()
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty)
        XCTAssertTrue(sut.isHistoryCleared)
    }
    
    func testClearHistoryWithEmptyHistoryStillSetsFlag() {
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty)
        sut.clearHistory()
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty)
        XCTAssertTrue(sut.isHistoryCleared)
    }
    
    func testHistoryClearedFlagResetsOnNewInstance() {
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        sut.clearHistory()
        XCTAssertTrue(sut.isHistoryCleared)
        let newViewModel = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
        XCTAssertFalse(newViewModel.isHistoryCleared)
    }
    
    // MARK: - Statistics Tests
    
    func testGetStatsWithHistoryReturnsValidStats() {
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test2", readingTime: 180)
        let stats = sut.getStats()
        XCTAssertEqual(stats.totalArticlesRead, 2)
        XCTAssertGreaterThan(stats.totalReadingTimeMinutes, 0)
        XCTAssertGreaterThan(stats.averageReadingTimeMinutes, 0)
    }
    
    func testGetStatsWithEmptyHistoryReturnsZeroStats() {
        let stats = sut.getStats()
        XCTAssertEqual(stats.totalArticlesRead, 0)
        XCTAssertEqual(stats.totalReadingTimeMinutes, 0)
        XCTAssertEqual(stats.averageReadingTimeMinutes, 0)
    }
    
    func testStatsConsistencyUniqueArticles() {
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 60)
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        let stats = sut.getStats()
        XCTAssertEqual(stats.totalArticlesRead, 1, "Should count unique articles only")
    }
    
    // MARK: - AppContainer Integration Test
    
    func testAppContainerIntegrationProducesWorkingViewModel() {
        let containerVM = AppContainer.shared.makeSettingsViewModel()
        XCTAssertEqual(containerVM.selectedLanguage, "ru")
        containerVM.changeLanguage(to: "en")
        XCTAssertEqual(containerVM.selectedLanguage, "en")
        containerVM.clearHistory()
        XCTAssertTrue(containerVM.isHistoryCleared)
    }
    
    // MARK: - UserDefaults Integration Test
    
    func testLanguagePersistenceAfterChange() {
        sut.changeLanguage(to: "en")
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en")
    }
    
    // MARK: - Isolation Test
    
    func testIsolatedUserDefaultsStartsWithDefaults() {
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
}
