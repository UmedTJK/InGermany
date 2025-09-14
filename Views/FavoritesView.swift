//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            List(favoritesManager.favoriteArticles(from: articles)) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article,
                        favoritesManager: favoritesManager,
                        selectedLanguage: selectedLanguage
                    )
                } label: {
                    ArticleRow(
                        article: article,
                        favoritesManager: favoritesManager
                    )
                }
            }
            .navigationTitle("Избранное")
        }
    }
}

#Preview {
    FavoritesView(
        favoritesManager: FavoritesManager(),
        articles: [Article.sampleArticle]
    )
}
