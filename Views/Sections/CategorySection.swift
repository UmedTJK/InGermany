//
//  CategorySection.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

import SwiftUI

struct CategorySection: View {
    let category: Category
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр (после category)
    let articles: [Article]               // ВТОРОЙ параметр
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @EnvironmentObject private var ratingManager: RatingManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: "ru"))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(articles.filter { $0.categoryId == category.id }) { article in
                        NavigationLink(
                            destination: ArticleView(
                                article: article,
                                allArticles: articles,
                                favoritesManager: favoritesManager
                            )
                            .environmentObject(ratingManager)
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
