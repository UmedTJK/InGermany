import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var selectedTab = 0
    @State private var articles: [Article] = []
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
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
            
            CategoriesView( // ← УБРАТЬ параметр categories
                articles: articles,
                favoritesManager: favoritesManager
            )
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
