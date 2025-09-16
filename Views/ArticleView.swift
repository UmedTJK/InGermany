//
//  ArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var ratingManager = RatingManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    private var relatedArticles: [Article] {
        allArticles
            .filter { $0.categoryId == article.categoryId && $0.id != article.id }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 🔹 Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                // 🔹 Категория
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

                // 🔹 Контент
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .foregroundColor(.primary)

                // 🔹 Рейтинг
                VStack(alignment: .leading, spacing: 4) {
                    Text("Оцените статью:")
                        .font(.subheadline)
                    HStack {
                        ForEach(1..<6) { star in
                            Image(systemName: star <= ratingManager.rating(for: article.id) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    ratingManager.setRating(star, for: article.id)
                                }
                        }
                    }
                }
                .padding(.top)

                // 🔹 Кнопка "Поделиться"
                ShareLink(
                    item: "\(article.localizedTitle(for: selectedLanguage))\n\n\(article.localizedContent(for: selectedLanguage))",
                    subject: Text(article.localizedTitle(for: selectedLanguage)),
                    message: Text("Поделитесь этой статьёй")
                ) {
                    Label("Поделиться статьёй", systemImage: "square.and.arrow.up")
                        .padding(.top)
                }

                // 🔹 Похожие статьи
                if !relatedArticles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Похожие статьи")
                            .font(.headline)
                            .padding(.top)

                        ForEach(relatedArticles) { related in
                            NavigationLink(destination: ArticleView(
                                article: related,
                                allArticles: allArticles,
                                favoritesManager: favoritesManager
                            ))
 {
                                VStack(alignment: .leading) {
                                    Text(related.localizedTitle(for: selectedLanguage))
                                        .font(.subheadline)
                                        .bold()
                                    Text(related.localizedContent(for: selectedLanguage))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
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
            allArticles: DataService.shared.loadArticles(),
            favoritesManager: FavoritesManager()
        )
    }
}
