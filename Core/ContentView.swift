//
//  ContentView.swift
//  InGermany
//
//  Created by SUM TJK on 12.09.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var selectedTab = 0
    @State private var articles: [Article] = []                  // 🔹 добавлено
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(favoritesManager: favoritesManager)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Главная",
                            language: selectedLanguage
                        ),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)
            
            // 🔹 передаём реальные статьи и favoritesManager в нужном порядке
            SearchView(favoritesManager: favoritesManager, articles: articles)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Поиск",
                            language: selectedLanguage
                        ),
                        systemImage: "magnifyingglass"
                    )
                }
                .tag(1)
            
            FavoritesView(favoritesManager: favoritesManager)
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Избранное",
                            language: selectedLanguage
                        ),
                        systemImage: "star.fill"
                    )
                }
                .tag(2)
            
            // 🔹 передаём требуемые параметры в CategoriesView
            CategoriesView(
                categories: CategoriesStore.shared.categories,
                articles: articles,
                favoritesManager: favoritesManager
            )
            .tabItem {
                Label(
                    LocalizationManager.shared.getTranslation(
                        key: "Категории",
                        language: selectedLanguage
                    ),
                    systemImage: "square.grid.2x2.fill"
                )
            }
            .tag(3)
            
            SettingsView()
                .tabItem {
                    Label(
                        LocalizationManager.shared.getTranslation(
                            key: "Настройки",
                            language: selectedLanguage
                        ),
                        systemImage: "gearshape.fill"
                    )
                }
                .tag(4)
        }
        // 🔹 грузим статьи один раз на старте
        .task {
            articles = await DataService.shared.loadArticles()
        }
    }
}
