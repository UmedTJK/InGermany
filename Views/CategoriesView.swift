//
//  CategoriesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
//  CategoriesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//

//
//  CategoriesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  CategoriesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct CategoriesView: View {
    let categories: [Category]
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            List(categories, id: \.id) { category in
                NavigationLink(
                    destination: ArticlesByCategoryView(
                        category: category,
                        articles: articles,
                        favoritesManager: favoritesManager
                    )
                ) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.blue)
                        Text(category.localizedName(for: selectedLanguage))
                    }
                }
            }
            .navigationTitle("Категории")
        }
    }
}

#Preview {
    CategoriesView(
        categories: [
            Category(
                id: "1",
                name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen"],
                icon: "banknote"
            )
        ],
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
