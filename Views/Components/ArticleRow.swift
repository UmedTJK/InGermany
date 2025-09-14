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
//  Created by SUM TJK on 13.09.25.
//

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
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let category = CategoryManager.shared.category(for: article.categoryId) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Text(category.localizedName(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Image(systemName: favoritesManager.isFavorite(id: article.id) ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRow(
        article: Article(
            id: "1",
            title: ["ru": "Заголовок", "en": "Title", "de": "Titel"],
            content: ["ru": "Содержимое", "en": "Content", "de": "Inhalt"],
            categoryId: "1",
            tags: ["финансы", "налоги"]
        ),
        favoritesManager: FavoritesManager()
    )
}
