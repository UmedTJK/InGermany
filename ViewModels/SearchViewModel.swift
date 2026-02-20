//
//  SearchViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages article search, filtering by text and tags, and provides search results for the UI.
@MainActor
class SearchViewModel: ObservableObject {
    /// List of all articles available for search.
    @Published var articles: [Article] = []
    /// Current search query text entered by the user.
    @Published var searchText: String = ""
    /// The tag currently selected for filtering, if any.
    @Published var selectedTag: String? = nil
    /// Indicates whether articles are being loaded.
    @Published var isLoading: Bool = true
    /// The last source of article data (cache, local, network).
    @Published var dataSource: String = "unknown"
    /// Текущий язык интерфейса, используется для локализации поиска
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Manager for handling favorite articles.
    let favoritesManager: FavoritesManagingProtocol
    /// Repository for retrieving categories.
    private let categoriesRepo: CategoriesRepositoryProtocol
    /// Repository for loading articles.
    private let articlesRepo: ArticlesRepositoryProtocol

    /// Injects dependencies.
    init(
        favoritesManager: FavoritesManagingProtocol,
        categoriesRepo: CategoriesRepositoryProtocol,
        articlesRepo: ArticlesRepositoryProtocol
    ) {
        self.favoritesManager = favoritesManager
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
    }

    // MARK: - Filtering
    /// Возвращает статьи, отфильтрованные по выбранному тегу и поисковому запросу
    var filteredArticles: [Article] {
        var results = articles
        if let tag = selectedTag {
            results = results.filter { $0.tags.contains(tag) }
        }
        if !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            results = results.filter { article in
                article.localizedTitle(for: selectedLanguage).lowercased().contains(lowercased) ||
                article.localizedContent(for: selectedLanguage).lowercased().contains(lowercased) ||
                categoriesRepo.category(by: article.categoryId)?
                    .localizedName(for: selectedLanguage)
                    .lowercased()
                    .contains(lowercased) ?? false
            }
        }
        return results
    }

    // MARK: - Tags
    /// Возвращает список всех уникальных тегов из статей
    var allTags: [String] {
        Set(articles.flatMap { $0.tags }).sorted()
    }

    // MARK: - Data loading
    /// Загружает статьи из репозитория и обновляет состояние загрузки
    func loadArticles() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.loadArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }
}
