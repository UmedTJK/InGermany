import SwiftUI

struct SearchView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]

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
                        ArticleRow(article: article) // ✅ убрал favoritesManager
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(getTranslation(key: "Поиск", language: selectedLanguage))
            .searchable(
                text: $searchText,
                prompt: getTranslation(key: "Искать по статьям или категориям", language: selectedLanguage)
            )
        }
    }

    // MARK: - Translation
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Поиск": [
                "ru": "Поиск",
                "en": "Search",
                "de": "Suche",
                "tj": "Ҷустуҷӯ",
                "fa": "جستجو",
                "ar": "بحث",
                "uk": "Пошук"
            ],
            "Искать по статьям или категориям": [
                "ru": "Искать по статьям или категориям",
                "en": "Search articles or categories",
                "de": "Artikel oder Kategorien suchen",
                "tj": "Ҷустуҷӯ аз рӯи мақолаҳо ё категорияҳо",
                "fa": "جستجو در مقالات یا دسته‌ها",
                "ar": "ابحث في المقالات أو الفئات",
                "uk": "Шукати за статтями чи категоріями"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
