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

    // MARK: - Concurrency guards
    /// Prevents stale async loads from overwriting newer state.
    private var loadGeneration: UInt64 = 0

    // MARK: - Search memoization
    /// Cache of lowercased searchable blobs per (articleId, language).
    /// Key format: "\(articleId)|\(language)"
    private var searchBlobCache: [String: String] = [:]

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
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !query.isEmpty else { return results }

            results = results.filter { article in
                searchableBlob(for: article).contains(query)
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
        loadGeneration &+= 1
        let gen = loadGeneration

        isLoading = true
        defer {
            // Only the latest generation may end loading.
            if gen == loadGeneration {
                isLoading = false
            }
        }

        guard !Task.isCancelled, gen == loadGeneration else { return }

        let loaded = await articlesRepo.loadArticles()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        let source = await articlesRepo.getLastSource()
        guard !Task.isCancelled, gen == loadGeneration else { return }

        // Commit state (still on MainActor).
        self.searchBlobCache.removeAll(keepingCapacity: true)
        self.articles = loaded
        self.dataSource = source
    }

    private func searchableBlob(for article: Article) -> String {
        let key = "\(article.id)|\(selectedLanguage)"
        if let cached = searchBlobCache[key] {
            return cached
        }

        // Build a single lowercased blob used for "contains" checks.
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let categoryName = categoriesRepo.category(by: article.categoryId)?
            .localizedName(for: selectedLanguage) ?? ""

        let blob = "\(title)\n\(categoryName)\n\(content)".lowercased()
        searchBlobCache[key] = blob
        return blob
    }
}
