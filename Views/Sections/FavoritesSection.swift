//
//  FavoritesSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//

import SwiftUI

/// Секция, отображающая избранные статьи в горизонтальном списке.
struct FavoritesSection: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager

    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init(
        articles: [Article],
        favoritesManager: FavoritesManager
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
    }

    var body: some View {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)

        if !favoriteArticles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(t("section_favorites"))
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(favoriteArticles) { article in
                            NavigationLink {
                                ArticleDetailView(
                                    article: article,
                                    allArticles: articles,
                                    appContainer: appContainer
                                )
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

    /// Возвращает перевод строки по ключу.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
