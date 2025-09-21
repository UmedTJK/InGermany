//
//  ContentView.swift
//  InGermany
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @EnvironmentObject private var readingHistoryManager: ReadingHistoryManager
    @EnvironmentObject private var ratingManager: RatingManager

    @State private var articles: [Article] = []
    @State private var locations: [Location] = []

    var body: some View {
        TabView {
            // 🔹 Домой
            NavigationStack {
                HomeView(
                    favoritesManager: favoritesManager,
                    articles: articles
                )
            }
            .tabItem {
                Label(
                    localizationManager.translate("HomeTab"),
                    systemImage: "house"
                )
            }

            // 🔹 Категории
            NavigationStack {
                CategoriesView(
                    favoritesManager: favoritesManager,
                    articles: articles,
                    categories: categoriesStore.categories
                )
            }
            .tabItem {
                Label(
                    localizationManager.translate("CategoriesTab"),
                    systemImage: "square.grid.2x2"
                )
            }

            // 🔹 Поиск
            NavigationStack {
                SearchView(
                    favoritesManager: favoritesManager,
                    articles: articles
                )
            }
            .tabItem {
                Label(
                    localizationManager.translate("SearchTab"),
                    systemImage: "magnifyingglass"
                )
            }

            // 🔹 Избранное
            NavigationStack {
                FavoritesView(
                    favoritesManager: favoritesManager,
                    articles: articles
                )
            }
            .tabItem {
                Label(
                    localizationManager.translate("FavoritesTab"),
                    systemImage: "star.fill"
                )
            }

            // 🔹 Настройки (здесь переходов нет — можно оставить без NavigationStack)
            SettingsView()
                .tabItem {
                    Label(
                        localizationManager.translate("SettingsTab"),
                        systemImage: "gear"
                    )
                }
        }
        .task {
            // Загружаем данные
            self.articles = await DataService.shared.loadArticles()
            self.locations = await DataService.shared.loadLocations()
            await categoriesStore.bootstrap()
        }
    }
}
