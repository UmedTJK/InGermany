//
//  RecentlyReadSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// A view that displays a section of recently read articles based on the user's reading history.
struct RecentlyReadSection: View {
    /// All available articles to display from.
    let articles: [Article]
    /// Manager responsible for handling favorite articles.
    let favoritesManager: FavoritesManager
    /// Manager responsible for tracking and providing recently read articles.
    let readingHistoryManager: ReadingHistoryManager

    /// Conditionally builds the "Недавно прочитанное" section with horizontally scrollable compact article cards if reading history is not empty.
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
                                    allArticles: articles
                                )
                            } label: {
                                /// Карточка компактного вида статьи, ведущая на экран её деталей
                                ArticleCompactCard(article: article)
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
