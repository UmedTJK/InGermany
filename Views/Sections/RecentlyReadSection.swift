//
//  RecentlyReadSection.swift
//  InGermany
//

import SwiftUI

struct RecentlyReadSection: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager
    let readingStatsManager: ReadingStatsManaging
    @EnvironmentObject private var appContainer: AppContainer

    init(
        articles: [Article],
        favoritesManager: FavoritesManager,
        readingStatsManager: ReadingStatsManaging
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.readingStatsManager = readingStatsManager
    }

    var body: some View {
        let recentlyRead = readingStatsManager.recentlyReadArticles(from: articles, limit: 5)

        if !recentlyRead.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Недавно прочитанное")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(recentlyRead) { article in
                            NavigationLink {
                                ArticleDetailView(
                                    article: article,
                                    allArticles: articles,
                                    appContainer: appContainer
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
}
