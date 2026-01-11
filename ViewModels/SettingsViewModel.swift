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
    private let settings: SettingsManagingProtocol
    private let localizationManager: LocalizationManager
    private let statsManager: ReadingStatsManagingProtocol

    // MARK: - Published
    @Published var isHistoryCleared: Bool = false

    // MARK: - Supported languages
    let supportedLanguages = ["ru", "en", "de", "tj", "fa", "ar", "uk"]

    // MARK: - Init
    init(
        settings: SettingsManagingProtocol,
        localizationManager: LocalizationManager,
        statsManager: ReadingStatsManagingProtocol
    ) {
        self.settings = settings
        self.localizationManager = localizationManager
        self.statsManager = statsManager
    }

    // MARK: - Settings (proxy)

    var selectedLanguage: String {
        get { settings.selectedLanguage }
        set { settings.selectedLanguage = newValue }
    }

    var isDarkMode: Bool {
        get { settings.isDarkMode }
        set { settings.isDarkMode = newValue }
    }

    var relativeDates: Bool {
        get { settings.relativeDates }
        set { settings.relativeDates = newValue }
    }

    // MARK: - Localization

    func localizedText(_ key: String) -> String {
        localizationManager.getTranslation(
            key: key,
            language: selectedLanguage
        )
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

    // MARK: - Card Style

    var selectedCardStyle: CardImageStyle {
        get {
            let all = Array(CardImageStyle.allCases)
            return all.indices.contains(settings.selectedCardStyleIndex)
                ? all[settings.selectedCardStyleIndex]
                : all.first!
        }
        set {
            if let idx = Array(CardImageStyle.allCases).firstIndex(of: newValue) {
                settings.selectedCardStyleIndex = idx
            }
        }
    }

    // MARK: - Stats

    var totalArticlesRead: Int {
        statsManager.totalArticlesRead
    }

    var formattedTotalReadingTime: String {
        statsManager.formatReadingTime(
            statsManager.totalReadingTimeMinutes,
            language: selectedLanguage
        )
    }

    var formattedAverageReadingTime: String {
        let total = statsManager.totalReadingTimeMinutes
        let count = max(statsManager.totalArticlesRead, 1)
        return statsManager.formatReadingTime(
            total / count,
            language: selectedLanguage
        )
    }

    var currentStreak: Int {
        // Пока ReadingStats не хранит streak
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
        settings.resetToDefaults()
        clearHistory()
    }
}
