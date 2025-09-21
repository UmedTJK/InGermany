//
//  ArticlesByTagView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр (после tag)
    let articles: [Article]               // ВТОРОЙ параметр
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
                    favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                    article: article
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
        favoritesManager: FavoritesManager(), // ИСПРАВЛЕНО порядок
        articles: [Article.sampleArticle]
    )
}
