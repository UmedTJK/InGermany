import SwiftUI

struct SearchView: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр - изменено на let
    let articles: [Article]               // ВТОРОЙ параметр

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var searchText: String = ""
    @State private var selectedTag: String? = nil
    @EnvironmentObject private var categoriesStore: CategoriesStore

    private var filteredArticles: [Article] {
        var results = articles
        if let tag = selectedTag {
            results = results.filter { $0.tags.contains(tag) }
        }
        if !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            results = results.filter { article in
                article.localizedTitle(for: selectedLanguage).lowercased().contains(lowercased) ||
                article.localizedContent(for: selectedLanguage).lowercased().contains(lowercased) ||
                categoriesStore.categoryName(for: article.categoryId, language: selectedLanguage)
                    .lowercased()
                    .contains(lowercased)
            }
        }
        return results
    }

    var body: some View {
        NavigationView {
            VStack {
                let allTags = Set(articles.flatMap { $0.tags }).sorted()
                if !allTags.isEmpty {
                    TagFilterView(tags: allTags) { tag in
                        selectedTag = (selectedTag == tag) ? nil : tag
                    }
                    .padding(.horizontal)
                }
                List(filteredArticles) { article in
                    NavigationLink {
                        ArticleView(
                            article: article,
                            allArticles: articles,
                            favoritesManager: favoritesManager
                        )
                    } label: {
                        ArticleRow(
                            favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                            article: article
                        )
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(
                LocalizationManager.shared.translate("Search") // УБРАЛИ language
            )
            .searchable(
                text: $searchText,
                prompt: LocalizationManager.shared.translate("SearchPrompt") // УБРАЛИ language
            )
        }
    }
}
