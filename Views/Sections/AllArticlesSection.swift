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
    let favoritesManager: any FavoritesManagingProtocol

    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    init(
        articles: [Article],
        favoritesManager: any FavoritesManagingProtocol,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
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
                                viewModel: makeDetailViewModel(article, articles),
                                localizationManager: localizationManager,
                                articleRowFactory: makeRowViewModel
                            )
                        } label: {
                            ArticleCompactCard(
                                viewModel: makeRowViewModel(article)
                            )
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
