//
//  ContentView.swift
//  InGermany
//

import SwiftUI

/// Обёртка для ленивой инициализации во вкладках
struct LazyView<Content: View>: View {
    private let build: () -> Content
    init(_ build: @escaping () -> Content) { self.build = build }
    var body: some View { build() }
}

struct ContentView: View {
    @EnvironmentObject var appContainer: AppContainer
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var readingStatsManager: ReadingStatsManager
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // ✅ HomeView через DI
            LazyView { HomeView(appContainer: appContainer) }
                .tabItem {
                    Label(localizationManager.t("tab_home"), systemImage: "house")
                }
                .tag(0)
            
            // ✅ CategoriesView через DI
            LazyView { CategoriesView(appContainer: appContainer) }
                .tabItem {
                    Label(localizationManager.t("tab_categories"), systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            // ✅ SearchView через фабрику из контейнера
            LazyView { SearchView(viewModel: appContainer.makeSearchViewModel()) }
                .tabItem {
                    Label(localizationManager.t("tab_search"), systemImage: "magnifyingglass")
                }
                .tag(2)
            
            // ✅ FavoritesView через фабрику из контейнера
            LazyView { FavoritesView(viewModel: appContainer.makeFavoritesViewModel()) }
                .tabItem {
                    Label(localizationManager.t("tab_favorites"), systemImage: "star.fill")
                }
                .tag(3)
            
            // ✅ SettingsView через фабрику из контейнера
            LazyView { SettingsView(viewModel: appContainer.makeSettingsViewModel()) }
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
        .environmentObject(AppContainer.previewMock())   // ✅ вместо shared
        .environmentObject(LocalizationManager.shared)
        .environmentObject(FavoritesManager.shared)
        .environmentObject(ReadingStatsManager.shared)
}
