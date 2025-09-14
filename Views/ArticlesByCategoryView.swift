//
//  ArticlesByCategoryView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

///
//  ArticlesByCategoryView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink(
                destination: ArticleView(article: article, favoritesManager: favoritesManager)
            ) {
                ArticleRow(article: article, favoritesManager: favoritesManager)
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
            id: "1",
            name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen"],
            icon: "banknote"
        ),
        articles: [
            Article(
                id: "1",
                title: ["ru": "Заголовок", "en": "Title", "de": "Titel"],
                content: ["ru": "Содержимое", "en": "Content", "de": "Inhalt"],
                categoryId: "1",
                tags: ["финансы", "налоги"]
            )
        ],
        favoritesManager: FavoritesManager()
    )
}
