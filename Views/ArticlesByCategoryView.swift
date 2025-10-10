//
//  ArticlesByCategoryView.swift
//  InGermany
//

//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

/// Экран, отображающий список статей, относящихся к определённой категории.
struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article]

    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("cardStyle") private var cardStyleRaw: String = CardStyle.standard.rawValue

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink(value: article) {
                ArticleRow(
                    viewModel: appContainer.makeArticleRowViewModel(article: article)
                )
                .applyCardStyle(CardStyle(rawValue: cardStyleRaw) ?? .standard)
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
        // ✅ Навигация по Article
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(
                viewModel: appContainer.makeArticleDetailViewModel(
                    article: article,
                    allArticles: articles
                ),
                localizationManager: appContainer.localizationManager,
                articleRowFactory: appContainer.makeArticleRowViewModel
            )
        }
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.categoryId == category.id }
    }
}

#Preview {
    let container = AppContainer.shared
    let sampleCategory = Category(
        id: "finance",
        name: ["ru": "Финансы", "en": "Finance"],
        icon: "banknote",
        colorHex: "#008000"
    )
    let sampleArticles = Article.sampleArticles

    return NavigationStack {
        ArticlesByCategoryView(category: sampleCategory, articles: sampleArticles)
            .environmentObject(container)
    }
}
