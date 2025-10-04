//
//  RecentlyReadSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// Displays a section of recently read articles based on reading history.
struct RecentlyReadSection: View {
    /// Список всех доступных статей
    let articles: [Article]
    /// Менеджер избранного для интеграции с карточками
    let favoritesManager: FavoritesManager
    /// Менеджер истории чтения для получения недавно прочитанных статей
    let readingHistoryManager: ReadingHistoryManager

    /// Строит секцию с заголовком 'Недавно прочитанное' и горизонтальной прокруткой карточек статей
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
