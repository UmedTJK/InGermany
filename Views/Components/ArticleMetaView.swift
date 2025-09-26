//
//  ArticleMetaView.swift
//  InGermany
//

import SwiftUI

struct ArticleMetaView: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru" // 🔹 Добавить это
    @ObservedObject private var ratingManager = RatingManager.shared
    @ObservedObject private var historyManager = ReadingHistoryManager.shared
    @EnvironmentObject private var categoriesStore: CategoriesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // 🔹 Категория
                if let category = categoriesStore.category(for: article.categoryId) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .blue)
                            .frame(width: 14, height: 14)

                        Text(category.localizedName(for: selectedLanguage)) // 🔹 Используем selectedLanguage
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // 🔹 Рейтинг
                if ratingManager.rating(for: article.id) > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(ratingManager.rating(for: article.id))/5")
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
                    Text(article.formattedReadingTime(for: selectedLanguage)) // 🔹 Используем selectedLanguage
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 🔹 Даты
            HStack(spacing: 12) {
                Text("\(t("Опубликовано")): \(article.formattedCreatedDate(for: selectedLanguage))") // 🔹 Используем selectedLanguage
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if article.updatedAt != nil {
                    Text("\(t("Обновлено")): \(article.formattedUpdatedDate(for: selectedLanguage))") // 🔹 Используем selectedLanguage
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
                
                if historyManager.isRead(article.id) {
                    BadgeView(text: t("Прочитано"), color: .orange)
                }
            }
        }
    }
    
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

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
        .environmentObject(CategoriesStore.shared)
        .padding()
}
#endif
