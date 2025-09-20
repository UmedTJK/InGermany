//
//  ArticlesByTagView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    article: article,
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow(
                    article: article,
                    favoritesManager: favoritesManager
                )
            }
        }
        .navigationTitle("#\(tag)")
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.tags.contains(tag) }
    }
}

#Preview {
    ArticlesByTagView(
        tag: "финансы",
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager()
    )
}
