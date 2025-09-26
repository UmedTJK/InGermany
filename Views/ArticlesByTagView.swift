//
//  ArticlesByTagView.swift
//  InGermany
//

import SwiftUI

struct ArticlesByTagView: View {
    let tag: String
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        List {
            ForEach(filteredArticles, id: \.id) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article,
                        allArticles: articles,
                        favoritesManager: favoritesManager
                    )
                } label: {
                    ArticleRow(article: article)
                }
            }
        }
        .navigationTitle("#\(tag)")
    }

    // Локально переводим теги и фильтруем по локализованному/сырому значению
    private var filteredArticles: [Article] {
        articles.filter { article in
            let localized = article.tags.map { t($0) }
            return localized.contains(tag) || article.tags.contains(tag)
        }
    }

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

#Preview {
    ArticlesByTagView(
        tag: "Финансы",
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager()
    )
}
