//
//  ArticlesByTagView.swift
//  InGermany
//

import SwiftUI

/// Displays a list of articles filtered by a specific tag.
struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    @EnvironmentObject var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List {
            ForEach(filteredArticles, id: \.id) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article, // Убрать viewModel параметр
                        allArticles: articles,
                        appContainer: appContainer // Добавить
                    )
                } label: {
                    ArticleRow(viewModel: appContainer.makeArticleRowViewModel(article: article))
                }
            }
        }
        .navigationTitle("#\(tag)")
    }

    private var filteredArticles: [Article] {
        articles.filter { article in
            let localized = article.tags.map { t($0) }
            return localized.contains(tag) || article.tags.contains(tag)
        }
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    ArticlesByTagView(
        tag: "Финансы",
        articles: [Article.sampleArticle]
    )
    .environmentObject(AppContainer.previewMock())
}
