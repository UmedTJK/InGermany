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
                                    favoritesManager: favoritesManager
                                )
                            } label: {
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

