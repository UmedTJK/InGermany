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
    /// Менеджер рейтингов для отображения текущего рейтинга статьи.
    @ObservedObject private var ratingManager = RatingManager.shared
    /// Менеджер истории чтения (зарезервировано для будущего использования).
    @ObservedObject private var historyManager = ReadingHistoryManager.shared
    /// Репозиторий категорий для получения названия и цвета категории.
    @StateObject private var categoriesRepository = DefaultCategoriesRepository.shared

    /// Основное содержимое: категория, рейтинг, время чтения, даты и бейджи.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // 🔹 Категория
                if let category = categoriesRepository.category(by: article.categoryId) { // ← ИСПРАВЛЕНО
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
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 🔹 Даты
            HStack(spacing: 12) {
                Text("\(t("Опубликовано")): \(article.formattedCreatedDate(for: selectedLanguage))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if article.updatedAt != nil {
                    Text("\(t("Обновлено")): \(article.formattedUpdatedDate(for: selectedLanguage))")
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
                
                // УБРАТЬ: historyManager.isRead - метода нет
                // if historyManager.isRead(article.id) {
                //     BadgeView(text: t("Прочитано"), color: .orange)
                // }
            }
        }
    }
    
    /// Локализует строку по ключу для выбранного языка.
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
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
    ArticleMetaView(article: Article.sampleArticle)
        .padding()
}
#endif
