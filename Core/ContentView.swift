//
//  ContentView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  ContentView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        TabView {
            // Главная
            NavigationView {
                HomeView(favoritesManager: favoritesManager)
            }
            .tabItem {
                Label("Главная", systemImage: "house.fill")
            }

            // Категории
            NavigationView {
                CategoriesView(favoritesManager: favoritesManager)
            }
            .tabItem {
                Label("Категории", systemImage: "square.grid.2x2")
            }

            // Поиск
            NavigationView {
                SearchView(favoritesManager: favoritesManager)
            }
            .tabItem {
                Label("Поиск", systemImage: "magnifyingglass")
            }

            // Избранное
            NavigationView {
                FavoritesView(favoritesManager: favoritesManager)
            }
            .tabItem {
                Label("Избранное", systemImage: "star.fill")
            }

            // Настройки
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    ContentView()
}
