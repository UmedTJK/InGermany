//
//  ArticlesByTagView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

//
//  ArticlesByTagView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    let selectedLanguage: String

    var body: some View {
        List(filteredArticles) { article in
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
        favoritesManager: FavoritesManager(),
        selectedLanguage: "ru"
    )
}
