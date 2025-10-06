//
//  ArticlesByTagView.swift
//  InGermany
//

import SwiftUI

/// Displays a list of articles filtered by a specific tag.
struct ArticlesByTagView: View {
    /// The tag used for filtering articles.
    let tag: String
    /// The complete list of articles to filter from.
    let articles: [Article]
    /// Shared manager to track favorites.
    @ObservedObject var favoritesManager: FavoritesManager
    /// Current UI language, stored in AppStorage.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Builds the list of filtered articles with navigation to `ArticleDetailView`.
    var body: some View {
        List {
            ForEach(filteredArticles, id: \.id) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article,
                        allArticles: articles
                    )
                } label: {
                    ArticleRow(viewModel: ArticleRowViewModel(article: article))
                }
            }
        }
        .navigationTitle("#\(tag)")
    }

    /// Performs filtering by localized or raw tag values.
    private var filteredArticles: [Article] {
        articles.filter { article in
            let localized = article.tags.map { t($0) }
            return localized.contains(tag) || article.tags.contains(tag)
        }
    }

    /// Retrieves the localized translation for a tag key.
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

#Preview {
    ArticlesByTagView(
        tag: "Финансы",
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager.shared // ← ИСПРАВЛЕНО
    )
}
