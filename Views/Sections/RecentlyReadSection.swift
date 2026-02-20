//
//  RecentlyReadSection.swift
//  InGermany
//

import SwiftUI

struct RecentlyReadSection: View {
    let articles: [Article]
    let favoritesManager: any FavoritesManagingProtocol
    let readingStatsManager: any ReadingStatsManagingProtocol
    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

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
                                    viewModel: appContainer.makeArticleDetailViewModel(
                                        article: article,
                                        allArticles: articles
                                    ),
                                    localizationManager: appContainer.localizationManager,
                                    articleRowFactory: appContainer.makeArticleRowViewModel
                                )
                            } label: {
                                ArticleCompactCard(
                                    viewModel: appContainer.makeArticleRowViewModel(article: article)
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
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
