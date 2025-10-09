import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - AppStorage Properties
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("cardImageStyle") var cardImageStyle: CardImageStyle = .bottomCorners
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
        localizationManager: LocalizationManager
    ) {
        self.readingStatsManager = readingStatsManager
        self.localizationManager = localizationManager
        setupReactiveBindings()
    }

    // MARK: - Public Methods
    
    /// Очистка истории чтения
    func clearHistory() {
        readingStatsManager.clearHistory()
        isHistoryCleared = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isHistoryCleared = false
        }
    }
    
    /// Смена языка
    func changeLanguage(to lang: String) {
        selectedLanguage = lang
    }
    
    /// Возвращает агрегированную статистику чтения
    public func getStats() -> ReadingStats {
        return readingStatsManager.getStats()
    }
    
    /// Provides localized text for the given key
    func localizedText(_ key: String, language: String? = nil) -> String {
        localizationManager.getTranslation(
            key: key,
            language: language ?? selectedLanguage
        )
    }
    
    /// Resets all settings to default values
    func resetToDefaults() {
        isDarkMode = false
        cardImageStyle = .bottomCorners
        relativeDates = true
        selectedLanguage = "ru"
    }
    
    // MARK: - Private Methods
    private func setupReactiveBindings() {
        // пока ничего не нужно
    }
}

// MARK: - Preview Support
extension SettingsViewModel {
    static func previewMock() -> SettingsViewModel {
        SettingsViewModel(
            readingStatsManager: ReadingStatsManager.shared,
            localizationManager: LocalizationManager.shared
        )
    }
    
    static func previewMockWithStats() -> SettingsViewModel {
        let vm = SettingsViewModel(
            readingStatsManager: ReadingStatsManager.shared,
            localizationManager: LocalizationManager.shared
        )
        return vm
    }
}
