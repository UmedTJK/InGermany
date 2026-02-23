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
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, DS.Spacing.contentInset)
            } else {
                List(filteredArticles) { article in
                    NavigationLink(value: article) {
                        ArticleRow(viewModel: articleRowFactory(article))
                            .frame(minHeight: DS.Size.hitTarget)
                            .contentShape(Rectangle())
                            .padding(.vertical, DS.Spacing.s)
                            .padding(.horizontal, DS.Spacing.m)
                            .cardContainer(.standard())
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(article.localizedTitle(for: selectedLanguage)))
                            .accessibilityHint(Text(localizationManager.getTranslation(key: "a11y_open_article_hint", language: selectedLanguage)))
                    }
                    .buttonStyle(.plain)
                    .cardPressFeedback()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(
                            top: DS.Spacing.s,
                            leading: DS.Spacing.contentInset,
                            bottom: DS.Spacing.s,
                            trailing: DS.Spacing.contentInset
                        )
                    )
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
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

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.section) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack(alignment: .center, spacing: DS.Spacing.m) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.getTranslation(key: "section_all_articles", language: selectedLanguage))
                            .font(.headline)

                        Text(localizationManager.getTranslation(key: "search_no_results", language: selectedLanguage))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                Text(localizationManager.getTranslation(key: "search_prompt", language: selectedLanguage))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DS.Spacing.section)
            .cardContainer(.standard(useMaterial: true))

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .contain)
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
