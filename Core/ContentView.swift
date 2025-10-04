import SwiftUI


/// The main entry point of the app UI, containing the tab navigation.
struct ContentView: View {
    /// Shared instance for managing favorite articles.
    @StateObject private var favoritesManager = FavoritesManager.shared
    /// Currently selected tab index.
    @State private var selectedTab = 0
    /// List of loaded articles.
    @State private var articles: [Article] = []
    /// User-selected app language.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    /// Builds the tabbed interface with Home, Categories, Search, Favorites, and Settings.
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_home", comment: ""),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)
            
            CategoriesView()
            .tabItem {
                Label(
                    NSLocalizedString("tab_categories", comment: ""),
                    systemImage: "square.grid.2x2.fill"
                )
            }
            .tag(1)
            
            SearchView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_search", comment: ""),
                        systemImage: "magnifyingglass"
                    )
                }
                .tag(2)
            
            FavoritesView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_favorites", comment: ""),
                        systemImage: "star.fill"
                    )
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_settings", comment: ""),
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(4)
        }
        .task {
            articles = await DataService.shared.loadArticles()
        }
    }
}
