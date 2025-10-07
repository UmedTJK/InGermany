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
    private let historyManager: ReadingHistoryManager
    private let localizationManager: LocalizationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        historyManager: ReadingHistoryManager,
        localizationManager: LocalizationManager = LocalizationManager.shared
    ) {
        self.historyManager = historyManager
        self.localizationManager = localizationManager
        
        // Setup reactive bindings for additional AppStorage properties if needed
        setupReactiveBindings()
    }
    
    // MARK: - Public Methods
    
    /// Очистка истории чтения
    func clearHistory() {
        historyManager.clearHistory()
        isHistoryCleared = true
        
        // Reset the flag after a delay for UI feedback
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
        return historyManager.getStats()
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
        // Ничего здесь не нужно, убери содержимое
    }

}

// MARK: - Preview Support
extension SettingsViewModel {
    static func previewMock() -> SettingsViewModel {
        let viewModel = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
        return viewModel
    }
    
    static func previewMockWithStats() -> SettingsViewModel {
        let viewModel = SettingsViewModel(historyManager: ReadingHistoryManager.shared)
        
        // Simulate some reading history for preview
        // Note: In real implementation, you might want to inject a mock history manager
        return viewModel
    }
}
