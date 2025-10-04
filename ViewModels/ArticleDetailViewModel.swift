//
//  ArticleDetailViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
//
//  ArticleDetailViewModel.swift
//  InGermany
//

import SwiftUI

/// Manages the state and actions for the article detail screen,
/// including favorites, PDF export, and reading history.
@MainActor
class ArticleDetailViewModel: ObservableObject {
    /// Indicates whether the article is marked as favorite.
    @Published var isFavorite: Bool
    /// The currently displayed article.
    let article: Article
    /// The list of all available articles.
    let allArticles: [Article]

    /// Manager responsible for handling favorite articles.
    private let favoritesManager: FavoritesManager
    /// Manager responsible for tracking reading history.
    private let historyManager: ReadingHistoryManager

    /// Sets up dependencies and initializes the favorite state.
    init(
        article: Article,
        allArticles: [Article],
        favoritesManager: FavoritesManager,
        historyManager: ReadingHistoryManager
    ) {
        self.article = article
        self.allArticles = allArticles
        self.favoritesManager = favoritesManager
        self.historyManager = historyManager
        self.isFavorite = favoritesManager.isFavorite(article.id)
    }

    // MARK: - Favorites
    /// Toggles the article's favorite status.
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    // MARK: - PDF Export
    /// Exports the article's content to a PDF file.
    func exportToPDF() {
        ExportToPDF.export(
            title: article.localizedTitle(for: "ru"),
            content: article.localizedContent(for: "ru"),
            fileName: article.pdfFileName ?? article.id
        )
    }

    // MARK: - Reading History
    /// Records that the article was read in the reading history.
    func markAsRead() {
        historyManager.addReadingEntry(articleId: article.id, readingTime: 0)
    }
}
