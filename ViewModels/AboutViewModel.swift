import SwiftUI

@MainActor
class AboutViewModel: ObservableObject {
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""
    @Published var repositoryURL: String = "https://github.com/UmedTJK/InGermany"
    
    init() {
        loadVersionInfo()
    }
    
    private func loadVersionInfo() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }
}
