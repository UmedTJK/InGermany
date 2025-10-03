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

@MainActor
class ArticleDetailViewModel: ObservableObject {
    @Published var isFavorite: Bool
    let article: Article
    let allArticles: [Article]

    private let favoritesManager: FavoritesManager
    private let historyManager: ReadingHistoryManager

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
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }

    // MARK: - PDF Export
    func exportToPDF() {
        ExportToPDF.export(
            title: article.localizedTitle(for: "ru"),
            content: article.localizedContent(for: "ru"),
            fileName: article.pdfFileName ?? article.id
        )
    }

    // MARK: - Reading History
    func markAsRead() {
        historyManager.addEntry(articleId: article.id)
    }
}
