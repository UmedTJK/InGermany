//
//  ArticlesByCategoryView.swift
//  InGermany
//

//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    let selectedLanguage: String

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleView(
                    article: article,
                    favoritesManager: favoritesManager
                )
            } label: {
                VStack(alignment: .leading) {
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.headline)
                    Text(article.localizedContent(for: selectedLanguage))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.categoryId == category.id }
    }
}

#Preview {
    ArticlesByCategoryView(
        category: Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance"],
            icon: "banknote"
        ),
        articles: [
            Article.sampleArticle
        ],
        favoritesManager: FavoritesManager(),
        selectedLanguage: "ru"
    )
}
