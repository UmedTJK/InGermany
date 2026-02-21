//
//  ArticlesByCategoryView.swift
//  InGermany
//

import SwiftUI

/// Экран, отображающий список статей, относящихся к определённой категории.
struct ArticlesByCategoryView: View {
    let category: Category
    let articles: [Article]

    // MARK: - Dependencies (pure DI)
    private let localizationManager: LocalizationManager
    private let articleRowFactory: (Article) -> ArticleRowViewModel
    private let articleDetailFactory: (Article, [Article]) -> ArticleDetailViewModel

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("cardStyle") private var cardStyleRaw: String = CardStyle.standard.rawValue

    init(
        category: Category,
        articles: [Article],
        localizationManager: LocalizationManager,
        articleRowFactory: @escaping (Article) -> ArticleRowViewModel,
        articleDetailFactory: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        self.category = category
        self.articles = articles
        self.localizationManager = localizationManager
        self.articleRowFactory = articleRowFactory
        self.articleDetailFactory = articleDetailFactory
    }

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink(value: article) {
                ArticleRow(
                    viewModel: articleRowFactory(article)
                )
                .applyCardStyle(CardStyle(rawValue: cardStyleRaw) ?? .standard)
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
        // ✅ Навигация по Article
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(
                viewModel: articleDetailFactory(article, articles),
                localizationManager: localizationManager,
                articleRowFactory: articleRowFactory
            )
        }
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.categoryId == category.id }
    }
}

#Preview {
    let container = AppContainer.previewMock()
    let sampleCategory = Category(
        id: "finance",
        name: ["ru": "Финансы", "en": "Finance"],
        icon: "banknote",
        colorHex: "#008000"
    )
    let sampleArticles = Article.sampleArticles

    NavigationStack {
        ArticlesByCategoryView(
            category: sampleCategory,
            articles: sampleArticles,
            localizationManager: container.localizationManager,
            articleRowFactory: container.makeArticleRowViewModel,
            articleDetailFactory: { article, allArticles in
                container.makeArticleDetailViewModel(article: article, allArticles: allArticles)
            }
        )
    }
}
