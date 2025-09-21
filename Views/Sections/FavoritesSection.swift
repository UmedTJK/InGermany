//
//  FavoritesSection.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

import SwiftUI

struct FavoritesSection: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let articles: [Article]               // ВТОРОЙ параметр
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore

    var body: some View {
        let favs = favoritesManager.favoriteArticles(from: articles)
            .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }

        VStack(alignment: .leading, spacing: 12) {
            // 🔹 Используем translate без аргумента language
            Text(LocalizationManager.shared.translate("Favorites"))
                .font(.headline)
                .padding(.horizontal)

            if favs.isEmpty {
                Text(LocalizationManager.shared.translate("NoArticles"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(favs) { article in
                            NavigationLink(
                                destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                            ) {
                                FavoriteCard(
                                    favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                                    article: article
                                )
                                .environmentObject(categoriesStore)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
