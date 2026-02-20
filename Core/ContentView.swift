//
//  ContentView.swift
//  InGermany
//

import SwiftUI

/// Обёртка для ленивой инициализации во вкладках
struct LazyView<Content: View>: View {
    private let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        build()
    }
}

struct ContentView: View {

    @EnvironmentObject var appContainer: AppContainer
    @EnvironmentObject var localizationManager: LocalizationManager

    // ✅ Источник темы — SettingsManager
    @EnvironmentObject var settingsManager: SettingsManager

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            LazyView {
                HomeView(appContainer: appContainer)
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_home"),
                    systemImage: "house.fill"
                )
            }
            .tag(0)

            LazyView {
                CategoriesView(appContainer: appContainer)
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_categories"),
                    systemImage: "square.grid.2x2"
                )
            }
            .tag(1)

            LazyView {
                SearchView(
                    viewModel: appContainer.makeSearchViewModel()
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_search"),
                    systemImage: "magnifyingglass"
                )
            }
            .tag(2)

            LazyView {
                FavoritesView(
                    viewModel: appContainer.makeFavoritesViewModel()
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_favorites"),
                    systemImage: "heart.fill"
                )
            }
            .tag(3)

            LazyView {
                SettingsView(
                    viewModel: appContainer.makeSettingsViewModel()
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_settings"),
                    systemImage: "gearshape.fill"
                )
            }
            .tag(4)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)

        // 🌙 Реактивная тема — корректно
        .environment(
            \.colorScheme,
            settingsManager.isDarkMode ? .dark : .light
        )
    }
}

#Preview {
    ContentView()
        .appEnvironment(using: AppContainer.previewMock())
}
