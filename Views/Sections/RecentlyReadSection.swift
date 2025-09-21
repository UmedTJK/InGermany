//
//  RecentlyReadSection.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

import SwiftUI

struct RecentlyReadSection: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let articles: [Article]               // ВТОРОЙ параметр
    @EnvironmentObject private var ratingManager: RatingManager
    @EnvironmentObject private var readingHistoryManager: ReadingHistoryManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        let recent = readingHistoryManager.recentlyReadArticles(from: articles)

        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.translate("RecentlyRead")) // УБРАЛИ language параметр
                .font(.headline)
                .padding(.horizontal)

            if recent.isEmpty {
                Text(LocalizationManager.shared.translate("NoArticles")) // УБРАЛИ language параметр
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recent) { article in
                            NavigationLink {
                                ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                                .environmentObject(ratingManager)
                            } label: {
                                RecentArticleCard(
                                    favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                                    article: article
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
