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
                // Блок "Избранное"
                if !favoritesManager.favoriteArticles(from: articles).isEmpty {
                    Section(header: Text("Избранное")) {
                        ForEach(favoritesManager.favoriteArticles(from: articles)) { article in
                            NavigationLink(
                                destination: ArticleView(article: article, favoritesManager: favoritesManager)
                            ) {
                                ArticleRow(article: article, favoritesManager: favoritesManager)
                            }
                        }
                    }
                }

                // Блок "Все статьи"
                Section(header: Text("Все статьи")) {
                    ForEach(articles) { article in
                        NavigationLink(
                            destination: ArticleView(article: article, favoritesManager: favoritesManager)
                        ) {
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
        articles: [
            Article(
                id: "1",
                title: ["ru": "Заголовок", "en": "Title", "de": "Titel"],
                content: ["ru": "Содержимое", "en": "Content", "de": "Inhalt"],
                categoryId: "1",
                tags: ["финансы", "налоги"]
            )
        ]
    )
}
