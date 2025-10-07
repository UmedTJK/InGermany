//
//  AllArticlesSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// A section view displaying all available articles in a horizontally scrollable list.
struct AllArticlesSection: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager
    @EnvironmentObject private var appContainer: AppContainer

    init(
        articles: [Article],
        favoritesManager: FavoritesManager
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
    }

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
                                appContainer: appContainer
                            )
                        } label: {
                            // ✅ ИСПРАВЛЕНО: используем правильный вызов ViewModel
                            ArticleRow(viewModel: appContainer.makeArticleRowViewModel(article: article))
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
