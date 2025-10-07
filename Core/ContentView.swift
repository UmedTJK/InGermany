import SwiftUI

/// The main entry point of the app UI, containing the tab navigation.
struct ContentView: View {
    @StateObject private var appContainer = AppContainer.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        appContainer.localizationManager.getTranslation(key: "tab_home", language: appContainer.localizationManager.selectedLanguage),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Label(
                        appContainer.localizationManager.getTranslation(key: "tab_categories", language: appContainer.localizationManager.selectedLanguage),
                        systemImage: "square.grid.2x2.fill"
                    )
                }
                .tag(1)
            
            SettingsView(appContainer: appContainer)
                .tabItem {
                    Label(
                        appContainer.localizationManager.getTranslation(
                            key: "tab_settings",
                            language: appContainer.localizationManager.selectedLanguage
                        ),
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(4)

            
            FavoritesView()
                .tabItem {
                    Label(
                        appContainer.localizationManager.getTranslation(key: "tab_favorites", language: appContainer.localizationManager.selectedLanguage),
                        systemImage: "star.fill"
                    )
                }
                .tag(3)
            
            SettingsView(viewModel: appContainer.makeSettingsViewModel())
                .tabItem {
                    Label(
                        appContainer.localizationManager.getTranslation(key: "tab_settings", language: appContainer.localizationManager.selectedLanguage),
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(4)

        }
        .environmentObject(appContainer)
        .environmentObject(appContainer.favoritesManager)
        .environmentObject(appContainer.textSizeManager)
        .environmentObject(appContainer.localizationManager)
        .environmentObject(appContainer.readingProgressTracker)
        .environmentObject(appContainer.readingTimeTracker)
    }
}
