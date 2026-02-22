//
//  ArticlesByTagView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    
    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    private let articleRowFactory: (Article) -> ArticleRowViewModel
    private let articleDetailFactory: (Article, [Article]) -> ArticleDetailViewModel
    
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init(
        tag: String,
        articles: [Article],
        localizationManager: LocalizationManager,
        articleRowFactory: @escaping (Article) -> ArticleRowViewModel,
        articleDetailFactory: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        self.tag = tag
        self.articles = articles
        self.localizationManager = localizationManager
        self.articleRowFactory = articleRowFactory
        self.articleDetailFactory = articleDetailFactory
    }

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    viewModel: articleDetailFactory(article, articles),
                    localizationManager: localizationManager,
                    articleRowFactory: articleRowFactory
                )
            } label: {
                ArticleRow(viewModel: articleRowFactory(article))
                    .cardContainer()
                    .padding(.vertical, DS.Spacing.xs)
                    .frame(minHeight: DS.Size.hitTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(DS.Color.background)
        }
        .navigationTitle("#\(tag)")
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DS.Color.background)
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.tags.contains(tag) }
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()

    return ArticlesByTagView(
        tag: "финансы",
        articles: Article.sampleArticles,
        localizationManager: container.localizationManager,
        articleRowFactory: container.makeArticleRowViewModel,
        articleDetailFactory: { article, allArticles in
            container.makeArticleDetailViewModel(article: article, allArticles: allArticles)
        }
    )
}
