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
        Group {
            if filteredArticles.isEmpty {
                ContentUnavailableView(
                    localizationManager.getTranslation(key: "section_all_articles", language: selectedLanguage),
                    systemImage: "doc.text.magnifyingglass",
                    description: Text(localizationManager.getTranslation(key: "search_no_results", language: selectedLanguage))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredArticles) { article in
                    NavigationLink(value: article) {
                        ArticleRow(viewModel: articleRowFactory(article))
                            .cardContainer()
                            .padding(.vertical, DS.Spacing.xs)
                            .contentShape(Rectangle())
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(article.localizedTitle(for: selectedLanguage)))
                            .accessibilityHint(Text(localizationManager.getTranslation(key: "a11y_open_article_hint", language: selectedLanguage)))
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(DS.Color.background)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(DS.Color.background)
            }
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(
                viewModel: articleDetailFactory(article, articles),
                localizationManager: localizationManager,
                articleRowFactory: articleRowFactory
            )
        }
        .background(DS.Color.background)
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
