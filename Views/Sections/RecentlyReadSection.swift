//
//  RecentlyReadSection.swift
//  InGermany
//

import SwiftUI

struct RecentlyReadSection: View {
    let articles: [Article]
    let favoritesManager: any FavoritesManagingProtocol
    let readingStatsManager: any ReadingStatsManagingProtocol
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    init(
        articles: [Article],
        favoritesManager: any FavoritesManagingProtocol,
        readingStatsManager: any ReadingStatsManagingProtocol,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.readingStatsManager = readingStatsManager
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        let recentArticles = readingStatsManager.recentlyReadArticles(from: articles, limit: 7)

        if !recentArticles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(t("section_recently_read"))
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(recentArticles) { article in
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

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
