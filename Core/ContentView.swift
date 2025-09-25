import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var selectedTab = 0
    @State private var articles: [Article] = []
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(favoritesManager: favoritesManager)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Главная",
                            language: selectedLanguage
                        ),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)
            
            // 🔹 Категории теперь сразу после Главной
            CategoriesView(
                categories: CategoriesStore.shared.categories,
                articles: articles,
                favoritesManager: favoritesManager
            )
            .tabItem {
                Label(
                    LocalizationManager.shared.getTranslation(
                        key: "Категории",
                        language: selectedLanguage
                    ),
                    systemImage: "square.grid.2x2.fill"
                )
            }
            .tag(1)
            
            SearchView(favoritesManager: favoritesManager, articles: articles)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Поиск",
                            language: selectedLanguage
                        ),
                        systemImage: "magnifyingglass"
                    )
                }
                .tag(2)
            
            FavoritesView(favoritesManager: favoritesManager)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Избранное",
                            language: selectedLanguage
                        ),
                        systemImage: "star.fill"
                    )
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Настройки",
                            language: selectedLanguage
                        ),
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
