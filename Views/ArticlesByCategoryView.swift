//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article] // Все статьи
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow(article: article) // ✅ без favoritesManager
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
            name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen", "tj": "Молия"],
            icon: "banknote",
            colorHex: "#4A90E2"
        ),
        articles: [],
        favoritesManager: FavoritesManager()
    )
}
