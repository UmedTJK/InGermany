//
//  ContentView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    private let articles = DataService.shared.loadArticles()
    
    var body: some View {
        TabView {
            // Главная
            MainArticlesView(
                favoritesManager: favoritesManager,
                articles: articles,
                selectedLanguage: selectedLanguage
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Главная")
            }
            
            // Категории
            CategoriesView(
                categories: DataService.shared.loadCategories(),
                articles: articles,
                favoritesManager: favoritesManager,
                selectedLanguage: selectedLanguage
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Категории")
            }
            
            // Избранное
            FavoritesView(
                favoritesManager: favoritesManager,
                articles: articles,
                selectedLanguage: selectedLanguage
            )
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Избранное")
            }
            
            // Настройки
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Настройки")
                }
        }
    }
}

// Главная страница (список статей)
struct MainArticlesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    let selectedLanguage: String
    
    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article,
                        favoritesManager: favoritesManager,
                        selectedLanguage: selectedLanguage
                    )
                } label: {
                    VStack(alignment: .leading) {
                        Text(article.localizedTitle(for: selectedLanguage))
                            .font(.headline)
                        Text(article.localizedContent(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            .navigationTitle("Главная")
        }
    }
}

#Preview {
    ContentView()
}
