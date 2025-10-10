//
//  ArticleCompactCardViewModel.swift
//  InGermany
//

import Foundation
import Combine

/// ViewModel for `ArticleCompactCard`, providing dependencies and computed data.
@MainActor
final class ArticleCompactCardViewModel: ObservableObject {

    let readingProgressTracker: ReadingProgressTrackerProtocol
    let ratingManager: RatingManagerProtocol
    let categoriesRepo: CategoriesRepositoryProtocol
    let localizationManager: LocalizationManagerProtocol
    
    // ✅ Используем localizationManager для выбранного языка
    private var selectedLanguage: String {
        localizationManager.selectedLanguage
    }

    init(
        readingProgressTracker: ReadingProgressTrackerProtocol,
        ratingManager: RatingManagerProtocol,
        categoriesRepo: CategoriesRepositoryProtocol,
        localizationManager: LocalizationManagerProtocol
    ) {
        self.readingProgressTracker = readingProgressTracker
        self.ratingManager = ratingManager
        self.categoriesRepo = categoriesRepo
        self.localizationManager = localizationManager
    }

    func category(for article: Article) -> Category? {
        categoriesRepo.category(by: article.categoryId)
    }

    /// Возвращает данные для отображения категории: иконку, имя и цвет.
    /// Если категория не найдена, показывает фолбэк "Без категории".
    func categoryDisplay(for article: Article) -> (icon: String, name: String, colorHex: String) {
        if let category = category(for: article) {
            return (
                category.icon,
                category.localizedName(for: selectedLanguage),
                category.colorHex
            )
        } else {
            return (
                "questionmark.circle",
                localizationManager.getTranslation(key: "category_none", language: selectedLanguage),
                "#7f8c8d" // серый цвет по умолчанию
            )
        }
    }

    func rating(for articleId: String) -> Int {
        ratingManager.getRating(for: articleId)
    }

    func setRating(_ value: Int, for articleId: String) {
        ratingManager.setRating(value, for: articleId)
    }

    func readingProgress(for articleId: String) -> Double {
        readingProgressTracker.progressForArticle(articleId)
    }

    func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
