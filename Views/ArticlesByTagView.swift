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
    @AppStorage("cardStyle") private var cardStyleRaw: String = CardStyle.standard.rawValue

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
                    .applyCardStyle(CardStyle(rawValue: cardStyleRaw) ?? .standard) // ✅ применяем выбранный стиль
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
