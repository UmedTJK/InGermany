//
//  ArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//
//  ArticleView.swift
//  InGermany
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                // Категория
                HStack(spacing: 6) {
                    Image(systemName: "folder")
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

                // Содержимое
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
        }
        .navigationTitle(article.localizedTitle(for: selectedLanguage))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    favoritesManager.toggleFavorite(article: article)
                } label: {
                    Image(
                        systemName: favoritesManager.isFavorite(article: article)
                        ? "star.fill"
                        : "star"
                    )
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ArticleView(
            article: Article.sampleArticle,
            favoritesManager: FavoritesManager()
        )
    }
}
