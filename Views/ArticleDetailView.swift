//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

/// A detailed view displaying a single article with localized content, image, and user interactions.
struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    private let articleRowFactory: (Article) -> ArticleRowViewModel

    // MARK: - Init with DI
    init(
        viewModel: ArticleDetailViewModel,
        localizationManager: LocalizationManager,
        articleRowFactory: @escaping (Article) -> ArticleRowViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.localizationManager = localizationManager
        self.articleRowFactory = articleRowFactory
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Image
                // Используем imageName вместо imageNameOrNil
                if !viewModel.article.imageName.isEmpty && viewModel.article.imageName != "Logo" {
                    Image(viewModel.article.imageName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // MARK: - Title
                Text(viewModel.article.localizedTitle(for: selectedLanguage))
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                // MARK: - Tags
                if !viewModel.article.tags.isEmpty {
                    TagsView(
                        tags: viewModel.article.tags,
                        language: selectedLanguage,
                        localizationManager: localizationManager
                    )
                    .padding(.horizontal)
                }

                // MARK: - Content
                Text(viewModel.article.localizedContent(for: selectedLanguage))
                    .font(viewModel.currentFont)
                    .padding(.horizontal)

                // MARK: - Related Articles
                let related = viewModel.recommendedArticles
                if !related.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("related_articles"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(related) { relatedArticle in
                            NavigationLink {
                                // create a new detail VM via viewModel helper (DI-friendly)
                                ArticleDetailView(
                                    viewModel: viewModel.createChildViewModel(for: relatedArticle),
                                    localizationManager: localizationManager,
                                    articleRowFactory: articleRowFactory
                                )
                            } label: {
                                ArticleRow(viewModel: articleRowFactory(relatedArticle))
                                    .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Вызываем метод onAppear напрямую (не-async)
            viewModel.onAppear()
        }
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Convenience Initializer for backward compatibility
extension ArticleDetailView {
    init(
        article: Article,
        allArticles: [Article],
        appContainer: AppContainer
    ) {
        self.init(
            viewModel: appContainer.makeArticleDetailViewModel(article: article, allArticles: allArticles),
            localizationManager: appContainer.localizationManager,
            articleRowFactory: appContainer.makeArticleRowViewModel
        )
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    let article = Article.sampleArticle
    return ArticleDetailView(
        viewModel: container.makeArticleDetailViewModel(article: article, allArticles: Article.sampleArticles),
        localizationManager: container.localizationManager,
        articleRowFactory: container.makeArticleRowViewModel
    )
}
