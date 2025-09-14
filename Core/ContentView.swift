//
//  ContentView.swift
//  InGermany
//
//  Created by Umed Sabzaev on 13.09.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var articles: [Article] = []
    @State private var categories: [Category] = []
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        TabView {
            HomeView(favoritesManager: favoritesManager, articles: articles)
                .tabItem {
                    Label("Главная", systemImage: "house")
                }

            SearchView(favoritesManager: favoritesManager, articles: articles)
                .tabItem {
                    Label("Поиск", systemImage: "magnifyingglass")
                }

            CategoriesView(categories: categories, articles: articles, favoritesManager: favoritesManager)
                .tabItem {
                    Label("Категории", systemImage: "square.grid.2x2")
                }

            FavoritesView(favoritesManager: favoritesManager, articles: articles)
                .tabItem {
                    Label("Избранное", systemImage: "star.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
        .onAppear {
            loadArticles()
            loadCategories()
        }
    }

    private func loadArticles() {
        articles = DataService.shared.loadArticles()
    }

    private func loadCategories() {
        categories = DataService.shared.loadCategories()
    }
}


#Preview {
    ContentView()
}
