//
//  ContentView.swift
//  InGermany
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var readingStatsManager: ReadingStatsManager
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Label(localizationManager.t("tab_home"), systemImage: "house")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Label(localizationManager.t("tab_categories"), systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            SearchView(viewModel: AppContainer.shared.makeSearchViewModel())
                .tabItem {
                    Label(localizationManager.t("tab_search"), systemImage: "magnifyingglass")
                }
                .tag(2)
            
            FavoritesView(viewModel: AppContainer.shared.makeFavoritesViewModel())
                .tabItem {
                    Label(localizationManager.t("tab_favorites"), systemImage: "star.fill")
                }
                .tag(3)
            
            SettingsView(viewModel: AppContainer.shared.makeSettingsViewModel())
                .tabItem {
                    Label(localizationManager.t("tab_settings"), systemImage: "gearshape")
                }
                .tag(4)
        }
        // 🔹 Глобальное управление темой
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocalizationManager.shared)
        .environmentObject(FavoritesManager.shared)
        .environmentObject(ReadingStatsManager.shared)
}
