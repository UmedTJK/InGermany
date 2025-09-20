//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article] // Все статьи
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru" // Используем AppStorage
    
    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleView(
                    article: article,
                    allArticles: articles, // ✅ передаем все статьи
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow( // Используем существующий компонент
                    article: article,
                    favoritesManager: favoritesManager
                )
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
            colorHex: "#4A90E2"   // ✅ добавили цвет
        ),
        articles: [], // Пустой массив для preview
        favoritesManager: FavoritesManager()
    )
}

