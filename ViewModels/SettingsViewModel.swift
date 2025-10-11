//
//  SettingsViewModel.swift
//  InGermany
//

import SwiftUI
import Combine

/// ViewModel для экрана настроек
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    private let statsManager: ReadingStatsManaging

    // MARK: - AppStorage / Published properties
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("relativeDates") var relativeDates: Bool = true
    @AppStorage("selectedCardStyleIndex") private var selectedCardStyleIndex: Int = 0

    @Published var isHistoryCleared: Bool = false

    // MARK: - Supported languages
    let supportedLanguages = ["ru", "en", "de", "tj", "fa", "ar", "uk"]

    // MARK: - Init
    init(localizationManager: LocalizationManager, statsManager: ReadingStatsManaging) {
        self.localizationManager = localizationManager
        self.statsManager = statsManager
    }

    // MARK: - Localization
    func localizedText(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }

    func displayName(for code: String) -> String {
        switch code {
        case "ru": return "Русский"
        case "en": return "English"
        case "de": return "Deutsch"
        case "tj": return "Тоҷикӣ"
        case "fa": return "فارسی"
        case "ar": return "العربية"
        case "uk": return "Українська"
        default:   return code
        }
    }

    // MARK: - Card Style (через индекс)
    var selectedCardStyle: CardImageStyle {
        get {
            let all = Array(CardImageStyle.allCases)
            return all.indices.contains(selectedCardStyleIndex) ? all[selectedCardStyleIndex] : all.first!
        }
        set {
            if let idx = Array(CardImageStyle.allCases).firstIndex(of: newValue) {
                selectedCardStyleIndex = idx
            }
        }
    }

    // MARK: - Stats
    var totalArticlesRead: Int {
        statsManager.totalArticlesRead
    }

    var formattedTotalReadingTime: String {
        statsManager.formatReadingTime(statsManager.totalReadingTimeMinutes, language: selectedLanguage)
    }

    var formattedAverageReadingTime: String {
        let total = statsManager.totalReadingTimeMinutes
        let count = max(statsManager.totalArticlesRead, 1)
        return statsManager.formatReadingTime(total / count, language: selectedLanguage)
    }

    var currentStreak: Int {
        // пока ReadingStats не хранит streak → возвращаем 0
        0
    }

    // MARK: - Actions
    func clearHistory() {
        statsManager.clearHistory()
        isHistoryCleared = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isHistoryCleared = false
        }
    }

    func resetToDefaults() {
        selectedLanguage = "ru"
        isDarkMode = false
        relativeDates = true
        selectedCardStyleIndex = 0
        clearHistory()
    }
}
