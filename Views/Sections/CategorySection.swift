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
    let favoritesManager: FavoritesManager
    let language: String
    @EnvironmentObject private var appContainer: AppContainer

    init(
        category: Category,
        articles: [Article],
        favoritesManager: FavoritesManager,
        language: String
    ) {
        self.category = category
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.language = language
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: language))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles.prefix(10)) { article in
                        // Views/Sections/CategorySection.swift - ИСПРАВЛЕННАЯ версия
                        NavigationLink {
                            // ✅ ИСПРАВЛЕНО: используем фабричный метод
                            appContainer.makeArticleDetailView(article: article, allArticles: articles)
                        } label: {
                            ArticleCompactCard(viewModel: appContainer.makeArticleRowViewModel(article: article))
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
