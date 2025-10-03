//
//  ArticleDetailView.swift
//  InGermany
//
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init(viewModel: SearchViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AppContainer.shared.makeSearchViewModel())
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.allTags.isEmpty {
                    TagFilterView(tags: viewModel.allTags) { tag in
                        viewModel.selectedTag = (viewModel.selectedTag == tag) ? nil : tag
                    }
                    .padding(.horizontal)
                }
                List(viewModel.filteredArticles) { article in
                    NavigationLink {
                        ArticleDetailView(
                            article: article,
                            allArticles: viewModel.articles
                        )
                    } label: {
                        ArticleRow(viewModel: ArticleRowViewModel(article: article))
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(t("Поиск"))
            .searchable(
                text: $viewModel.searchText,
                prompt: t("Искать по статьям или категориям")
            )
            .task {
                await viewModel.loadArticles()
            }
        }
    }

    // 🔹 Шорткат для нового менеджера
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: self.selectedLanguage)
    }

    // 🔹 Старый метод (оставлен для совместимости)
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
