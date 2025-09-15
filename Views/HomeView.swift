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

//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]

    var body: some View {
        NavigationView {
            List {
                // 🔹 Новый раздел с картой
                Section(header: Text("Полезное")) {
                    NavigationLink(destination: MapView()) {
                        Label("Карта локаций", systemImage: "map")
                    }
                }

                if !favoritesManager.favoriteArticles(from: articles).isEmpty {
                    Section(header: Text("Избранное")) {
                        ForEach(favoritesManager.favoriteArticles(from: articles)) { article in
                            NavigationLink {
                                ArticleDetailView(
                                    article: article,
                                    favoritesManager: favoritesManager,
                                    selectedLanguage: selectedLanguage
                                )
                            } label: {
                                ArticleRow(article: article, favoritesManager: favoritesManager)
                            }
                        }
                    }
                }

                Section(header: Text("Все статьи")) {
                    ForEach(articles) { article in
                        NavigationLink {
                            ArticleDetailView(
                                article: article,
                                favoritesManager: favoritesManager,
                                selectedLanguage: selectedLanguage
                            )
                        } label: {
                            ArticleRow(article: article, favoritesManager: favoritesManager)
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
