//
//  CategorySection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// A reusable section displaying articles filtered by a given category.
struct CategorySection: View {
    /// The category for which articles are displayed
    let category: Category
    /// The list of all articles to filter by category
    let articles: [Article]
    /// The favorites manager for integration with article cards
    let favoritesManager: FavoritesManager
    /// The language code for localizing the category name
    let language: String

    /// Builds the UI for the category section with a title and horizontally scrollable article cards
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
                            /// Карточка компактного вида статьи, ведущая на её детальный экран
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
