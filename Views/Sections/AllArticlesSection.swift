//
//  AllArticlesSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

struct AllArticlesSection: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Все статьи")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles) { article in
                        NavigationLink {
                            ArticleDetailView(
                                article: article,
                                allArticles: articles,
                                favoritesManager: favoritesManager
                            )
                        } label: {
                            ArticleCompactCard(article: article)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 24)
    }
}

