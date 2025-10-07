//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

/// Displays a list of articles filtered by a specific category.
struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article]
    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    article: article, // Убрать viewModel параметр
                    allArticles: articles,
                    appContainer: appContainer // Добавить
                )
            } label: {
                ArticleRow(
                    viewModel: appContainer.makeArticleRowViewModel(article: article)
                )
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.categoryId == category.id }
    }
}

// MARK: - Preview
#Preview {
    ArticlesByCategoryView(
        category: Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen", "tj": "Молия"],
            icon: "banknote",
            colorHex: "#4A90E2"
        ),
        articles: Article.sampleArticles
    )
    .environmentObject(AppContainer.previewMock())
}
