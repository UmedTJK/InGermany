//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            if favoritesManager.favoriteArticles(from: articles).isEmpty {
                Text("У вас пока нет избранных статей")
                    .foregroundColor(.secondary)
                    .padding()
                    .navigationTitle("Избранное")
            } else {
                List {
                    ForEach(favoritesManager.favoriteArticles(from: articles)) { article in
                        NavigationLink(
                            destination: ArticleView(article: article, favoritesManager: favoritesManager)
                        ) {
                            ArticleRow(article: article, favoritesManager: favoritesManager)
                        }
                    }
                }
                .navigationTitle("Избранное")
            }
        }
    }
}

#Preview {
    FavoritesView(
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
