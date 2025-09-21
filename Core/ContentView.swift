//
//  ContentView.swift
//  InGermany
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @StateObject private var favoritesManager = FavoritesManager()
    
    let articles: [Article]
    let categories: [Category]
    
    var body: some View {
        TabView {
            HomeView(favoritesManager: favoritesManager)
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
