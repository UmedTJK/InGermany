//
//  CategorySection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

struct CategorySection: View {
    let category: Category
    let articles: [Article]
    let favoritesManager: FavoritesManager
    let language: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: language))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles.prefix(10)) { article in
                        NavigationLink {
                            ArticleDetailView(
                                article: article,
                                allArticles: articles
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

