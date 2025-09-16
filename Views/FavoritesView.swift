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
            List(favoritesManager.favoriteArticles(from: articles)) { article in
                NavigationLink {
                    ArticleView(
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
            .navigationTitle("Избранное (\(favoritesManager.favoriteArticles(from: articles).count))")
        }
    }
}

#Preview {
    FavoritesView(
        favoritesManager: FavoritesManager(),
        articles: [Article.sampleArticle]
    )
}
