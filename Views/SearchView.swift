//
//  SearchView.swift
//  InGermany
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var searchText: String = ""

    private var filteredArticles: [Article] {
        if searchText.isEmpty {
            return articles
        } else {
            let lowercased = searchText.lowercased()
            return articles.filter { article in
                article.localizedTitle(for: selectedLanguage).lowercased().contains(lowercased) ||
                article.localizedContent(for: selectedLanguage).lowercased().contains(lowercased) ||
                (CategoryManager.shared
                    .category(for: article.categoryId)?
                    .localizedName(for: selectedLanguage)
                    .lowercased()
                    .contains(lowercased) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredArticles) { article in
                NavigationLink {
                    ArticleDetailView(
                        article: article,
                        favoritesManager: favoritesManager,
                        selectedLanguage: selectedLanguage
                    )
                } label: {
                    ArticleRow(
                        article: article,
                        favoritesManager: favoritesManager
                    )
                }
            }
            .navigationTitle("Поиск")
            .searchable(text: $searchText, prompt: "Искать по статьям или категориям")
        }
    }
}

#Preview {
    SearchView(
        favoritesManager: FavoritesManager(),
        articles: [Article.sampleArticle]
    )
}

