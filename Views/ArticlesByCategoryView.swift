//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI


/// Displays a list of articles filtered by a specific category.
struct ArticlesByCategoryView: View {
    /// The selected category to filter articles.
    let category: Category
    /// All available articles (filtered by category).
    let articles: [Article]
    /// Shared favorites manager to track favorite status.
    @ObservedObject var favoritesManager: FavoritesManager
    /// The current UI language stored in AppStorage.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    /// Builds the list UI with navigation to `ArticleDetailView` for each article.
    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    article: article,
                    allArticles: articles
                )
            } label: {
                ArticleRow(viewModel: ArticleRowViewModel(article: article))
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
    }
    
    /// Filters all articles by the given category.
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
        favoritesManager: FavoritesManager.shared // ← ИСПРАВЛЕНО
    )
}
