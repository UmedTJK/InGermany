//
//  RecentlyReadSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

struct RecentlyReadSection: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager
    let readingHistoryManager: ReadingHistoryManager
    @EnvironmentObject private var appContainer: AppContainer

    // ✅ Только один конструктор без appContainer
    init(
        articles: [Article],
        favoritesManager: FavoritesManager,
        readingHistoryManager: ReadingHistoryManager
    ) {
        self.articles = articles
        self.favoritesManager = favoritesManager
        self.readingHistoryManager = readingHistoryManager
    }

    var body: some View {
        let recentlyRead = readingHistoryManager.recentlyReadArticles(from: articles)

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
                                ArticleRow(
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
