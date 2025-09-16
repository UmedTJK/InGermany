//
//  SearchView.swift
//  InGermany
//

//

import SwiftUI

struct SearchView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var searchText: String = ""
    @State private var selectedTag: String? = nil

    private var filteredArticles: [Article] {
        var results = articles

        // Фильтрация по тегу
        if let tag = selectedTag {
            results = results.filter { $0.tags.contains(tag) }
        }

        // Фильтрация по тексту
        if !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            results = results.filter { article in
                article.localizedTitle(for: selectedLanguage).lowercased().contains(lowercased) ||
                article.localizedContent(for: selectedLanguage).lowercased().contains(lowercased) ||
                (CategoryManager.shared
                    .category(for: article.categoryId)?
                    .localizedName(for: selectedLanguage)
                    .lowercased()
                    .contains(lowercased) ?? false)
            }
        }

        return results
    }

    var body: some View {
        NavigationView {
            VStack {
                // 🔹 Отображение уникальных тегов
                let allTags = Set(articles.flatMap { $0.tags }).sorted()

                if !allTags.isEmpty {
                    TagFilterView(tags: allTags) { tag in
                        selectedTag = (selectedTag == tag) ? nil : tag
                    }
                    .padding(.horizontal)
                }

                // 🔹 Список статей
                List(filteredArticles) { article in
                    NavigationLink {
                        ArticleView(
                            article: article,
                            allArticles: articles, // ✅ теперь передаём список всех статей
                            favoritesManager: favoritesManager
                        )
                    } label: {
                        ArticleRow(
                            article: article,
                            favoritesManager: favoritesManager
                        )
                    }
                }
                .listStyle(.plain)
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
