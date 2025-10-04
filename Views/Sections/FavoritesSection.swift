//
//  FavoritesSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// Секция, отображающая избранные статьи в горизонтальном списке.
struct FavoritesSection: View {
    /// Содержит все статьи.
    let articles: [Article]
    /// Управляет списком избранных статей.
    let favoritesManager: FavoritesManager

    /// Строит UI с заголовком "Избранное" и списком карточек статей.
    var body: some View {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)

        if !favoriteArticles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Избранное")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(favoriteArticles) { article in
                            NavigationLink {
                                ArticleDetailView(
                                    article: article,
                                    allArticles: articles
                                )
                            } label: {
                                /// Каждая карточка отображает краткий вид статьи и ведёт на её детальный экран.
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
}
