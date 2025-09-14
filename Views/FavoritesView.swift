//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    let selectedLanguage: String   // 👈 принимаем язык как параметр

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
                    VStack(alignment: .leading) {
                        Text(article.localizedTitle(for: selectedLanguage))
                            .font(.headline)
                        Text(article.localizedContent(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            .navigationTitle("Избранное")
        }
    }
}

#Preview {
    FavoritesView(
        favoritesManager: FavoritesManager(),
        articles: [Article.sampleArticle],
        selectedLanguage: "ru"
    )
}
