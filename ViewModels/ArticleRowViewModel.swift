//
//  ArticleRowViewModel.swift
//  InGermany
//

import SwiftUI

/// ViewModel for displaying an article row/card in lists and favorites.
@MainActor
final class ArticleRowViewModel: ObservableObject, Identifiable {
    let id: String   // id статьи — строка
    let article: Article
    
    private let localizationManager: LocalizationManager
    private let favoritesManager: any FavoritesManagingProtocol
    private let ratingManager: RatingManager
    private let categoriesRepo: CategoriesRepositoryProtocol
    private let readingStatsManager: ReadingStatsManagingProtocol
    private let articleFormatter: ArticleFormatter
    
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @Published var isFavorite: Bool
    @Published var rating: Int
    
    init(
        article: Article,
        localizationManager: LocalizationManager,
        favoritesManager: any FavoritesManagingProtocol,
        ratingManager: RatingManager,
        categoriesRepo: CategoriesRepositoryProtocol,
        readingStatsManager: ReadingStatsManagingProtocol,
        articleFormatter: ArticleFormatter
    ) {
        self.id = article.id
        self.article = article
        self.localizationManager = localizationManager
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager
        self.categoriesRepo = categoriesRepo
        self.readingStatsManager = readingStatsManager
        self.articleFormatter = articleFormatter
        
        self.isFavorite = favoritesManager.isFavorite(article.id)
        self.rating = ratingManager.getRating(for: article.id)
    }
    
    // MARK: - Image
    
    /// Имя изображения статьи или nil, если не задано
    var imageName: String? {
        article.image
    }
    
    // MARK: - Category
    
    var category: Category? {
        categoriesRepo.category(by: article.categoryId)
    }
    
    /// Возвращает локализованное имя категории или "Без категории"
    var categoryName: String {
        if let category = category {
            return category.localizedName(for: selectedLanguage)
        } else {
            return localizationManager.getTranslation(key: "category_none", language: selectedLanguage)
        }
    }
    
    // MARK: - Texts
    
    var title: String {
        article.localizedTitle(for: selectedLanguage)
    }
    
    var subtitle: String {
        "\(articleFormatter.readingTime(article, for: selectedLanguage)) " +
        localizationManager.getTranslation(key: "min", language: selectedLanguage)
    }
    
    var contentPreview: String {
        article.localizedContent(for: selectedLanguage)
    }
    
    /// Дополнительная информация: категория + теги
    var metaInfo: String {
        var parts: [String] = []
        
        // Категория
        parts.append(categoryName)
        
        // Первые два тега
        if !article.tags.isEmpty {
            let tagsString = article.tags.prefix(2).map { "#\($0)" }.joined(separator: " ")
            parts.append(tagsString)
        }
        
        return parts.joined(separator: " • ")
    }
    
    // MARK: - Favorites
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(for: article.id)
        isFavorite = favoritesManager.isFavorite(article.id)
    }
    
    // MARK: - Rating
    
    func setRating(_ newRating: Int) {
        ratingManager.setRating(newRating, for: article.id)
        rating = newRating
    }
    
    // MARK: - Reading stats
    
    var progress: CGFloat {
        readingStatsManager.progressForArticle(article.id)
    }
}
