//
//  SearchView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import SwiftUI

/// Экран поиска статей по заголовкам и тегам
//
//  SearchView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import SwiftUI

/// Экран поиска статей по заголовкам и тегам
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
                let titleMatch = article.localizedTitle(for: selectedLanguage).lowercased().contains(lowercased)
                let contentMatch = article.localizedContent(for: selectedLanguage).lowercased().contains(lowercased)
                let tagsMatch = article.tags.contains { $0.lowercased().contains(lowercased) }
                let categoryMatch: Bool = {
                    if let category = CategoryManager.shared.category(for: article.categoryId) {
                        return category.localizedName(for: selectedLanguage).lowercased().contains(lowercased)
                    }
                    return false
                }()
                return titleMatch || contentMatch || tagsMatch || categoryMatch
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredArticles) { article in
                NavigationLink(
                    destination: ArticleView(article: article, favoritesManager: favoritesManager)
                ) {
                    ArticleRow(article: article, favoritesManager: favoritesManager)
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
        articles: DataService.shared.loadArticles()
    )
}
