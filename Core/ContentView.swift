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
            
            LazyView { HomeView(appContainer: appContainer) }
                .tabItem {
                    Label(localizationManager.t("tab_home"), systemImage: "house.fill")
                }
                .tag(0)
            
            LazyView { CategoriesView(appContainer: appContainer) }
                .tabItem {
                    Label(localizationManager.t("tab_categories"), systemImage: "square.grid.2x2")
                }
                .tag(1)
            
            LazyView { SearchView(viewModel: appContainer.makeSearchViewModel()) }
                .tabItem {
                    Label(localizationManager.t("tab_search"), systemImage: "magnifyingglass")
                }
                .tag(2)
            
            LazyView { FavoritesView(viewModel: appContainer.makeFavoritesViewModel()) }
                .tabItem {
                    Label(localizationManager.t("tab_favorites"), systemImage: "star.fill")
                }
                .tag(3)
            
            LazyView { SettingsView(viewModel: appContainer.makeSettingsViewModel()) }
                .tabItem {
                    Label(localizationManager.t("tab_settings"), systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        // ⚡ Для iOS 17 остаётся blur, на iOS 18+ Liquid Glass включится автоматически
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .environment(\.colorScheme, isDarkMode ? ColorScheme.dark : ColorScheme.light)
        .onAppear {
            appContainer.bootstrap()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.previewMock())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(FavoritesManager.shared)
        .environmentObject(ReadingStatsManager.shared)
}
