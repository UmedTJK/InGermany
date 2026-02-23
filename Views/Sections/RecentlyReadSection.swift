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

        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            SectionHeader(title: t("section_recently_read"))

            if !recentArticles.isEmpty {
                HorizontalCarousel {
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
                        .buttonStyle(.plain)
                        .cardPressFeedback()
                    }
                }
            } else {
                emptyState
            }
        }
        .padding(.bottom, DS.Spacing.xl)
    }

    private var emptyState: some View {
        HStack(alignment: .center, spacing: DS.Spacing.m) {
            Image(systemName: "clock")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(t("Еще нет прочитанных"))
                    .font(.headline)

                Text(t("Откройте статью — и она появится здесь."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(DS.Spacing.section)
        .cardContainer(.standard(useMaterial: true))
        .accessibilityElement(children: .combine)
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
