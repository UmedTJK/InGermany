//
//  ArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  ArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                if let category = CategoryManager.shared.category(for: article.categoryId) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .foregroundColor(.blue)
                        Text(category.localizedName(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if !article.tags.isEmpty {
                    HStack {
                        ForEach(article.tags, id: \.self) { tag in
                            Label(tag, systemImage: "tag")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }

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
                    favoritesManager.toggleFavorite(id: article.id)
                } label: {
                    Label(
                        favoritesManager.isFavorite(id: article.id) ? "Удалить из избранного" : "Добавить в избранное",
                        systemImage: favoritesManager.isFavorite(id: article.id) ? "star.fill" : "star"
                    )
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ArticleView(
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
}
