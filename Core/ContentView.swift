//
//  ContentView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var articles: [Article] = []
    @State private var categories: [Category] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Загрузка данных...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                TabView {
                    HomeView(
                        favoritesManager: favoritesManager
                    )
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    CategoriesView(
                        categories: categories,
                        articles: articles,
                        favoritesManager: favoritesManager
                    )
                    .tabItem {
                        Label("Categories", systemImage: "square.grid.2x2.fill")
                    }
                    
                    SearchView(
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    
                    FavoritesView(
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        .task {
            await loadData()
        }
        .refreshable {
            await refreshData()
        }
    }
    
    private func loadData() async {
        let dataService = DataService.shared
        articles = await dataService.loadArticles()
        categories = await dataService.loadCategories()
        isLoading = false
    }
    
    private func refreshData() async {
        isLoading = true
        await DataService.shared.refreshData()
        articles = await DataService.shared.loadArticles()
        categories = await DataService.shared.loadCategories()
        isLoading = false
    }
}
