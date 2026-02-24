
import SwiftUI
// MARK: - Apple Localization
import Foundation

@main
struct InGermanyApp: App {

    @StateObject private var settingsManager: SettingsManager
    @StateObject private var appContainer: AppContainer
    @StateObject private var localizationSettings: LocalizationSettings

    init() {
        let sm = SettingsManager()
        _settingsManager = StateObject(wrappedValue: sm)
        _appContainer = StateObject(wrappedValue: AppContainer(settingsManager: sm))
        _localizationSettings = StateObject(wrappedValue: LocalizationSettings())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                makeHomeViewModel: appContainer.makeHomeViewModel,
                makeCategoriesViewModel: appContainer.makeCategoriesViewModel,
                makeSearchViewModel: appContainer.makeSearchViewModel,
                makeFavoritesViewModel: appContainer.makeFavoritesViewModel,
                makeSettingsViewModel: appContainer.makeSettingsViewModel,
                makeAboutViewModel: appContainer.makeAboutViewModel,
                makePDFLibraryViewModel: appContainer.makePDFLibraryViewModel,
                makeDataService: { appContainer.dataService },
                makeArticleRowViewModel: appContainer.makeArticleRowViewModel,
                makeArticleDetailViewModel: { article, all in
                    appContainer.makeArticleDetailViewModel(article: article, allArticles: all)
                },
                makeArticleDetailView: { article, all in
                    appContainer.makeArticleDetailView(article: article, allArticles: all)
                }
            )
                .appEnvironment(using: appContainer)
                .environmentObject(settingsManager)
                .environmentObject(localizationSettings)
                .environment(\.locale, localizationSettings.locale)

                // 🌙 ЕДИНСТВЕННЫЙ источник темы
                .preferredColorScheme(
                    settingsManager.isDarkMode ? .dark : .light
                )

                .environment(\.screenSize, UIScreen.main.bounds.size)
                .onAppear {
                    appContainer.bootstrap()

#if DEBUG
                    Task {
                        // Wait for initial bootstrap + async refresh
                        try? await Task.sleep(nanoseconds: 2_000_000_000)

                        let metricsDump = await appContainer.dumpNetworkMetrics()

                        print("""

📊 ================================
NETWORK METRICS SNAPSHOT (LAUNCH)
================================
\(metricsDump)
=================================

""")
                    }
#endif
                }
        }
    }
}
