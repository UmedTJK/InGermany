//
//  CategorySection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// A reusable section displaying articles filtered by a given category.
struct CategorySection: View {
    let category: Category
    let articles: [Article]
    let favoritesManager: any FavoritesManagingProtocol
    let language: String

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailView: (Article, [Article]) -> ArticleDetailView

    init(
        category: Category,
        articles: [Article],
        favoritesManager: any FavoritesManagingProtocol,
        language: String,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailView: @escaping (Article, [Article]) -> ArticleDetailView
    ) {
        self.category = category
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.language = language
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailView = makeDetailView
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: language))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles.prefix(10)) { article in
                        NavigationLink {
                            makeDetailView(article, articles)
                        } label: {
                            ArticleCompactCard(viewModel: makeRowViewModel(article))
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
