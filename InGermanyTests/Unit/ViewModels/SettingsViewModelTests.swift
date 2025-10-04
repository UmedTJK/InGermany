//
//  SettingsViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Clean up before each test - ОЧЕНЬ ВАЖНО: очищаем UserDefaults
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        ReadingHistoryManager.shared.clearForTesting()
        
        // Initialize ViewModel
        sut = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
    }
    
    override func tearDown() async throws {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        ReadingHistoryManager.shared.clearForTesting()
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // После очистки UserDefaults должен быть установлен язык по умолчанию "ru"
        XCTAssertEqual(sut.selectedLanguage, "ru", "Default language should be Russian after cleanup")
        XCTAssertFalse(sut.isHistoryCleared, "Initially history should not be cleared")
    }
    
    // MARK: - Language Management Tests
    
    func testChangeLanguage() {
        // Given - initial language
        XCTAssertEqual(sut.selectedLanguage, "ru")
        
        // When - change language
        sut.changeLanguage(to: "en")
        
        // Then - should update language
        XCTAssertEqual(sut.selectedLanguage, "en", "Should change to English")
        
        // Verify it persists in UserDefaults
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en", "Should persist language in UserDefaults")
    }
    
    func testChangeToUnsupportedLanguage() {
        // Given - initial language
        XCTAssertEqual(sut.selectedLanguage, "ru")
        
        // When - change to unsupported language
        sut.changeLanguage(to: "fr") // French not supported
        
        // Then - should still change (validation happens in UI)
        XCTAssertEqual(sut.selectedLanguage, "fr", "Should allow any language code")
    }
    
    func testMultipleLanguageChanges() {
        // Test sequence of language changes
        sut.changeLanguage(to: "en")
        XCTAssertEqual(sut.selectedLanguage, "en")
        
        sut.changeLanguage(to: "de")
        XCTAssertEqual(sut.selectedLanguage, "de")
        
        sut.changeLanguage(to: "ru")
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
    
    // MARK: - History Management Tests
    
    func testClearHistory() {
        // Given - some reading history exists
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        
        let initialHistory = ReadingHistoryManager.shared.history
        XCTAssertFalse(initialHistory.isEmpty, "Should have reading history initially")
        
        // When - clear history
        sut.clearHistory()
        
        // Then - history should be cleared and state updated
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty, "History should be empty after clearing")
        XCTAssertTrue(sut.isHistoryCleared, "isHistoryCleared flag should be true")
    }
    
    func testClearHistoryWithEmptyHistory() {
        // Given - empty history
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty, "Should start with empty history")
        
        // When - clear history
        sut.clearHistory()
        
        // Then - should still work without errors
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty, "History should remain empty")
        XCTAssertTrue(sut.isHistoryCleared, "isHistoryCleared flag should be true")
    }
    
    func testHistoryClearedFlagResets() {
        // Given - add history and clear it
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        sut.clearHistory()
        XCTAssertTrue(sut.isHistoryCleared, "Flag should be true after clearing")
        
        // When - create NEW ViewModel instance (симулируем перезапуск приложения)
        let newViewModel = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
        
        // Then - flag should be false in new instance
        XCTAssertFalse(newViewModel.isHistoryCleared, "Flag should be false in new ViewModel instance")
    }
    
    // MARK: - Statistics Tests
    
    func testGetStatsWithHistory() {
        // Given - reading history exists
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120)
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test2", readingTime: 180)
        
        // When - get stats
        let stats = sut.getStats()
        
        // Then - should return valid stats
        XCTAssertEqual(stats.totalArticlesRead, 2, "Should count 2 unique articles")
        XCTAssertGreaterThan(stats.totalReadingTimeMinutes, 0, "Should have positive reading time")
        XCTAssertGreaterThan(stats.averageReadingTimeMinutes, 0, "Should have positive average time")
    }
    
    func testGetStatsWithEmptyHistory() {
        // Given - empty history
        XCTAssertTrue(ReadingHistoryManager.shared.history.isEmpty)
        
        // When - get stats
        let stats = sut.getStats()
        
        // Then - should return zero stats
        XCTAssertEqual(stats.totalArticlesRead, 0, "Should have zero articles read")
        XCTAssertEqual(stats.totalReadingTimeMinutes, 0, "Should have zero reading time")
        XCTAssertEqual(stats.averageReadingTimeMinutes, 0, "Should have zero average time")
    }
    
    // MARK: - AppContainer Integration Test
    
    func testAppContainerIntegration() {
        // When - create via AppContainer
        let containerVM = AppContainer.shared.makeSettingsViewModel()
        
        // Then - should initialize properly
        XCTAssertEqual(containerVM.selectedLanguage, "ru", "Should have default language")
        
        // Проверяем что методы работают
        containerVM.changeLanguage(to: "en")
        XCTAssertEqual(containerVM.selectedLanguage, "en")
        
        // Проверяем очистку истории
        containerVM.clearHistory()
        XCTAssertTrue(containerVM.isHistoryCleared)
    }
    
    // MARK: - UserDefaults Integration Tests
    
    func testLanguagePersistence() {
        // Given - clean state
        XCTAssertEqual(sut.selectedLanguage, "ru")
        
        // When - change language
        sut.changeLanguage(to: "en")
        
        // Then - should persist in UserDefaults
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        XCTAssertEqual(savedLanguage, "en", "Should persist language in UserDefaults")
    }
    
    // MARK: - Edge Cases
    
    func testEmptyLanguageChange() {
        // Given - initial language
        XCTAssertEqual(sut.selectedLanguage, "ru")
        
        // When - change to empty string
        sut.changeLanguage(to: "")
        
        // Then - should handle gracefully
        XCTAssertEqual(sut.selectedLanguage, "", "Should allow empty language")
    }
    
    func testVeryLongLanguageCode() {
        // Given - initial language
        XCTAssertEqual(sut.selectedLanguage, "ru")
        
        // When - change to very long code
        let longCode = String(repeating: "a", count: 100)
        sut.changeLanguage(to: longCode)
        
        // Then - should handle gracefully
        XCTAssertEqual(sut.selectedLanguage, longCode, "Should handle long language codes")
    }
    
    // MARK: - Behavior Tests
    
    func testClearHistoryUpdatesFlag() {
        // Given - initial state
        XCTAssertFalse(sut.isHistoryCleared)
        
        // When - clear history
        sut.clearHistory()
        
        // Then - flag should be updated
        XCTAssertTrue(sut.isHistoryCleared, "Flag should be true after clearing history")
    }
    
    func testStatsConsistency() {
        // Given - multiple readings of same article
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 60)
        ReadingHistoryManager.shared.addReadingEntry(articleId: "test1", readingTime: 120) // Overwrites previous
        
        // When - get stats
        let stats = sut.getStats()
        
        // Then - should count unique articles only
        XCTAssertEqual(stats.totalArticlesRead, 1, "Should count unique articles only")
    }
    
    func testIsolatedUserDefaults() {
        // Этот тест проверяет что каждый тест изолирован
        XCTAssertEqual(sut.selectedLanguage, "ru", "Each test should start with clean UserDefaults")
    }
}
