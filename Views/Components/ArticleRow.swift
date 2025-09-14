//
//  ArticleRow.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  ArticleRow.swift
//  InGermany
//
//
//  ArticleRow.swift
//  InGermany
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // Заголовок статьи
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // Категория
                HStack(spacing: 6) {
                    Image(systemName: "folder")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    Text(
                        CategoryManager.shared
                            .category(for: article.categoryId)?
                            .localizedName(for: selectedLanguage)
                        ?? "Без категории"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            Spacer()
            
            // Индикатор "Избранное"
            Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRow(
        article: Article.sampleArticle,
        favoritesManager: FavoritesManager()
    )
}
