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
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                SectionHeader(title: t("section_recently_read"))

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: DS.Spacing.carouselItem) {
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
                    .padding(.horizontal, DS.Spacing.contentInset)
                    .padding(.vertical, DS.Spacing.carouselVPad)
                }
            }
            .padding(.bottom, DS.Spacing.xl)
        }
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
