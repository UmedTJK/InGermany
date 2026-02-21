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
    let favoritesManager: any FavoritesManagingProtocol

    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

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
        let favoriteArticles = articles.filter { favoritesManager.isFavorite($0.id) }

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

    /// Возвращает перевод строки по ключу.
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
