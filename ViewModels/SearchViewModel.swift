//
//  SearchViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var searchText: String = ""
    @Published var selectedTag: String? = nil
    @Published var isLoading: Bool = true
    @Published var dataSource: String = "unknown"
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    let favoritesManager: FavoritesManager
    private let categoriesRepo: CategoriesRepository
    private let articlesRepo: ArticlesRepository

    init(
        favoritesManager: FavoritesManager,
        categoriesRepo: CategoriesRepository,
        articlesRepo: ArticlesRepository
    ) {
        self.favoritesManager = favoritesManager
        self.categoriesRepo = categoriesRepo
        self.articlesRepo = articlesRepo
    }

    convenience init() {
        self.init(
            favoritesManager: FavoritesManager.shared,
            categoriesRepo: CategoriesRepository.shared,
            articlesRepo: ArticlesRepositoryImpl()
        )
    }

    // MARK: - Filtering
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
    var allTags: [String] {
        Set(articles.flatMap { $0.tags }).sorted()
    }

    // MARK: - Data loading
    func loadArticles() async {
        isLoading = true
        defer { isLoading = false }
        self.articles = await articlesRepo.loadArticles()
        self.dataSource = await articlesRepo.getLastSource()
    }
}
