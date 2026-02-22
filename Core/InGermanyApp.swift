import SwiftUI

@main
struct InGermanyApp: App {

    @StateObject private var settingsManager: SettingsManager
    @StateObject private var appContainer: AppContainer

    init() {
        let sm = SettingsManager()
        _settingsManager = StateObject(wrappedValue: sm)
        _appContainer = StateObject(wrappedValue: AppContainer(settingsManager: sm))
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

                // 🌙 ЕДИНСТВЕННЫЙ источник темы
                .preferredColorScheme(
                    settingsManager.isDarkMode ? .dark : .light
                )

                .environment(\.screenSize, UIScreen.main.bounds.size)
                .onAppear {
                    appContainer.bootstrap()
                }
        }
    }
}
