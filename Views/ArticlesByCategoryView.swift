//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    let favoritesManager: FavoritesManager
    let articles: [Article]

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var ratingManager: RatingManager

    var filteredArticles: [Article] {
        articles.filter { $0.categoryId == category.id }
    }

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink(
                destination: ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
                .environmentObject(ratingManager)
            ) {
                HStack {
                    Image("Logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.localizedTitle(for: selectedLanguage))
                            .font(.body)
                            .fontWeight(.medium)
                            .lineLimit(2)

                        if article.createdAt != nil {
                            Text(article.formattedCreatedDate(for: selectedLanguage))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
    }
}

#Preview {
    ArticlesByCategoryView(
        category: Category.sampleCategories[0],
        favoritesManager: FavoritesManager(),
        articles: Article.sampleArticles
    )
    .environmentObject(RatingManager.example)
}
