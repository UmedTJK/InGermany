//
//  ArticleMetaView.swift
//  InGermany
//

import SwiftUI

/// Отображает метаданные статьи: категорию, рейтинг, время чтения, даты публикации и бейджи (новое/обновлено).
struct ArticleMetaView: View {
    /// Статья, для которой отображаются метаданные.
    let article: Article
    
    /// Выбранный язык интерфейса для локализации.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let categoryProvider: any CategoriesRepositoryProtocol
    private let ratingManager: RatingManagerProtocol
    private let articleFormatter: ArticleFormatterProtocol

    init(
        article: Article,
        categoryProvider: any CategoriesRepositoryProtocol,
        ratingManager: any RatingManagerProtocol,
        articleFormatter: any ArticleFormatterProtocol
    ) {
        self.article = article
        self.categoryProvider = categoryProvider
        self.ratingManager = ratingManager
        self.articleFormatter = articleFormatter
    }

    /// Основное содержимое: категория, рейтинг, время чтения, даты и бейджи.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // 🔹 Категория
                if let category = categoryProvider.category(by: article.categoryId) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .blue)
                            .frame(width: 14, height: 14)

                        Text(category.localizedName(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // 🔹 Рейтинг
                let currentRating = ratingManager.getRating(for: article.id)
                if currentRating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(currentRating)/5")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // 🔹 Время чтения
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(formattedReadingTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 🔹 Даты
            HStack(spacing: 12) {
                Text("\(t("Опубликовано")): \(formattedCreatedDate)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if article.updatedAt != nil {
                    Text("\(t("Обновлено")): \(formattedUpdatedDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // 🔹 Бейджи
            HStack(spacing: 6) {
                if article.isNew {
                    BadgeView(text: t("Новое"), color: .green)
                }
                
                if article.isUpdatedRecently {
                    BadgeView(text: t("Обновлено"), color: .blue)
                }
            }
        }
    }
    
    // ✅ ДОБАВЛЕНО: Вычисляемые свойства для форматирования
    private var formattedReadingTime: String {
        let readingTime = articleFormatter.readingTime(article, for: selectedLanguage)
        return ReadingTimeCalculator.formatReadingTime(readingTime, language: selectedLanguage)
    }
    
    private var formattedCreatedDate: String {
        articleFormatter.formattedCreatedDate(article, for: selectedLanguage)
    }
    
    private var formattedUpdatedDate: String {
        articleFormatter.formattedUpdatedDate(article, for: selectedLanguage)
    }
    
    /// Локализует строку по ключу для выбранного языка.
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

/// Универсальный компонент бейджа с текстом и цветом.
struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}




#if DEBUG
#Preview {
    let container = AppContainer.previewMock()
    ArticleMetaView(
        article: Article.sampleArticle,
        categoryProvider: container.categoriesRepo,
        ratingManager: container.ratingManager,
        articleFormatter: container.makeArticleFormatter()
    )
    .environmentObject(container.localizationManager)
    .padding()
}
#endif
