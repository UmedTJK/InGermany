import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - AppStorage Properties
    @AppStorage("selectedLanguage") var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("relativeDates") var relativeDates: Bool = true
    
    // MARK: - Published Properties
    @Published var isHistoryCleared: Bool = false

    // MARK: - Dependencies
    private let readingStatsManager: ReadingStatsManaging
    private let localizationManager: LocalizationManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        readingStatsManager: ReadingStatsManaging,
        localizationManager: LocalizationManager = LocalizationManager.shared
    ) {
        self.readingStatsManager = readingStatsManager
        self.localizationManager = localizationManager
        setupReactiveBindings()
    }

    // MARK: - Public Methods
    func clearHistory() {
        readingStatsManager.clearHistory()
        isHistoryCleared = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isHistoryCleared = false
        }
    }

    func changeLanguage(to lang: String) {
        selectedLanguage = lang
    }

    public func getStats() -> ReadingStats {
        return readingStatsManager.getStats()
    }

    func localizedText(_ key: String, language: String? = nil) -> String {
        localizationManager.getTranslation(
            key: key,
            language: language ?? selectedLanguage
        )
    }

    func resetToDefaults() {
        isDarkMode = false
        relativeDates = true
        selectedLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    }

    private func setupReactiveBindings() {}

    // MARK: - Preview Support
    static func previewMock() -> SettingsViewModel {
        SettingsViewModel(readingStatsManager: ReadingStatsManager.shared)
    }

    static func previewMockWithStats() -> SettingsViewModel {
        SettingsViewModel(readingStatsManager: ReadingStatsManager.shared)
    }
}
