//
//  ArticlesByTagView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    
    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List(filteredArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    viewModel: appContainer.makeArticleDetailViewModel(
                        article: article,
                        allArticles: articles
                    ),
                    localizationManager: appContainer.localizationManager,
                    articleRowFactory: appContainer.makeArticleRowViewModel
                )
            } label: {
                ArticleRow(viewModel: appContainer.makeArticleRowViewModel(article: article))
            }
        }
        .navigationTitle("#\(tag)")
    }

    private var filteredArticles: [Article] {
        articles.filter { $0.tags.contains(tag) }
    }
}

// MARK: - Preview
#Preview {
    ArticlesByTagView(
        tag: "финансы",
        articles: Article.sampleArticles
    )
    .environmentObject(AppContainer.previewMock())
}
