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
    // Для Preview оставляем синхронную версию или используем mock данные
    ArticlesByCategoryView(
        category: Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen", "tj": "Молия"],
            icon: "banknote"
        ),
        articles: [], // Пустой массив для preview
        favoritesManager: FavoritesManager()
    )
}
