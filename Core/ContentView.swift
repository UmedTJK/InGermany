import SwiftUI

/// The main entry point of the app UI, containing the tab navigation.
struct ContentView: View {
    @StateObject private var appContainer = AppContainer()
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        localizationManager.getTranslation(key: "tab_home", language: localizationManager.selectedLanguage),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)

            CategoriesView() // ✅ ИСПРАВЛЕНО: убрал appContainer
                .tabItem {
                    Label(
                        localizationManager.getTranslation(key: "tab_categories", language: localizationManager.selectedLanguage),
                        systemImage: "square.grid.2x2.fill"
                    )
                }
                .tag(1)

            FavoritesView(appContainer: appContainer)
                .tabItem {
                    Label(
                        localizationManager.getTranslation(key: "tab_favorites", language: localizationManager.selectedLanguage),
                        systemImage: "star.fill"
                    )
                }
                .tag(2)

            SearchView(appContainer: appContainer)
                .tabItem {
                    Label(
                        localizationManager.getTranslation(key: "tab_search", language: localizationManager.selectedLanguage),
                        systemImage: "magnifyingglass"
                    )
                }
                .tag(3)

            SettingsView(viewModel: appContainer.makeSettingsViewModel())
                .tabItem {
                    Label(
                        localizationManager.getTranslation(key: "tab_settings", language: localizationManager.selectedLanguage),
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
        .environmentObject(appContainer.ratingManager)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(LocalizationManager.shared)
}
