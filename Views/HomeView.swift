//
//  HomeView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//


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

    var body: some View {
        NavigationView {
            List {
                // 🔹 Раздел с картой
                Section(header: Text("Полезное")) {
                    NavigationLink(destination: MapView()) {
                        Label("Карта локаций", systemImage: "map")
                    }
                }

                // 🔹 Избранные статьи
                let favorites = favoritesManager.favoriteArticles(from: articles)
                if !favorites.isEmpty {
                    Section(header: Text("Избранное (\(favorites.count))")) {
                        ForEach(favorites) { article in
                            NavigationLink {
                                ArticleView(
                                    article: article,
                                    allArticles: articles, // ✅ передаём allArticles
                                    favoritesManager: favoritesManager
                                )
                            } label: {
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
                        NavigationLink {
                            ArticleView(
                                article: article,
                                allArticles: articles, // ✅ передаём allArticles
                                favoritesManager: favoritesManager
                            )
                        } label: {
                            ArticleRow(
                                article: article,
                                favoritesManager: favoritesManager
                            )
                        }
                    }
                }
            }
            .navigationTitle("Главная")
        }
    }
}

#Preview {
    HomeView(
        favoritesManager: FavoritesManager(),
        articles: DataService.shared.loadArticles()
    )
}
