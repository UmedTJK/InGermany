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
    
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        TabView {
            HomeView(favoritesManager: favoritesManager)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CategoriesView(
                categories: categoriesStore.categories,
                articles: categoriesStore.articles,
                favoritesManager: favoritesManager
            )
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2.fill")
            }
            
            SearchView(
                favoritesManager: favoritesManager,
                articles: categoriesStore.articles
            )
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            FavoritesView(
                favoritesManager: favoritesManager,
                articles: categoriesStore.articles
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
