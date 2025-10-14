import SwiftUI

@MainActor
final class PDFViewerViewModel: ObservableObject {
    private let localizationManager: LocalizationManager
    
    init(localizationManager: LocalizationManager) {
        self.localizationManager = localizationManager
    }
    
    func t(_ key: String, language: String? = nil) -> String {
        localizationManager.t(key, language: language)
    }
}
