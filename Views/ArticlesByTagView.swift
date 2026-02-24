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
                    .frame(minHeight: DS.Size.hitTarget)
                    .contentShape(Rectangle())
                    .padding(.vertical, DS.Spacing.s)
                    .padding(.horizontal, DS.Spacing.m)
                    .cardContainer(.standard())
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
        .navigationTitle("#\(tag)")
        .listStyle(.plain)
        .scrollIndicators(.hidden)
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
