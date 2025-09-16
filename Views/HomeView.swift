//
//  HomeView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    
    // Состояние для управления навигацией к случайной статье
    @State private var isShowingRandomArticle = false
    @State private var randomArticle: Article?

    var body: some View {
        NavigationStack {
            List {
                // 🔹 Раздел с картой и случайной статьей
                Section(header: Text("Полезное")) {
                    // Карта локаций
                    NavigationLink {
                        MapView()
                    } label: {
                        Label("Карта локаций", systemImage: "map")
                    }
                    
                    // Кнопка "Случайная статья"
                    Button(action: {
                        // Выбираем случайную статью из всех доступных
                        randomArticle = articles.randomElement()
                        isShowingRandomArticle = true
                    }) {
                        Label("Случайная статья", systemImage: "dice.fill")
                            .foregroundColor(.primary)
                    }
                }

                // 🔹 Избранные статьи
                let favorites = favoritesManager.favoriteArticles(from: articles)
                if !favorites.isEmpty {
                    Section(header: Text("Избранное (\(favorites.count))")) {
                        ForEach(favorites) { article in
                            NavigationLink(value: article) {
                                ArticleRow(
                                    article: article,
                                    favoritesManager: favoritesManager
                                )
                            }
                        }
                    }
                }

                // 🔹 Все статьи
                Section(header: Text("Все статьи (\(articles.count))")) {
                    ForEach(articles) { article in
                        NavigationLink(value: article) {
                            ArticleRow(
                                article: article,
                                favoritesManager: favoritesManager
                            )
                        }
                    }
                }
            }
            .navigationTitle("Главная")
            .navigationDestination(for: Article.self) { article in
                ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            }
            .navigationDestination(isPresented: $isShowingRandomArticle) {
                Group {
                    if let randomArticle {
                        ArticleView(
                            article: randomArticle,
                            allArticles: articles,
                            favoritesManager: favoritesManager
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(
        favoritesManager: FavoritesManager(),
        articles: DataService.shared.loadArticles()
    )
}
