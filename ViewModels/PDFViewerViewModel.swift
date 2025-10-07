import SwiftUI

@MainActor
final class PDFViewerViewModel: ObservableObject {
    let localizationManager: LocalizationManager
    
    init(localizationManager: LocalizationManager) {
        self.localizationManager = localizationManager
    }
    
    func localizedPDFText(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: localizationManager.selectedLanguage)
    }
}
