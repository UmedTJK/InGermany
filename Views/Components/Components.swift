//
//  Components.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

import SwiftUI

// MARK: - ToolCard

struct ToolCard: View {
    let title: String
    let systemImage: String
    let color: Color
    
    private enum Metrics {
        static let iconSize: CGFloat = 24
        static let iconContainer: CGFloat = 50
        static let cardWidth: CGFloat = 120
        static let cardHeight: CGFloat = 120
        static let spacing: CGFloat = 8
    }
    
    var body: some View {
        VStack(spacing: Metrics.spacing) {
            Image(systemName: systemImage)
                .font(.system(size: Metrics.iconSize, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: Metrics.iconContainer, height: Metrics.iconContainer)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(DS.Spacing.m)
        .frame(width: Metrics.cardWidth, height: Metrics.cardHeight)
        .cardContainer(.standard())
    }
}



// MARK: - RecentArticleCard

struct RecentArticleCard: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    private enum Metrics {
        static let spacing: CGFloat = 12
        static let imageSize: CGFloat = 60
        static let imageRadius: CGFloat = 8
    }

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Metrics.imageSize, height: Metrics.imageSize)
                    .cornerRadius(Metrics.imageRadius)
                    .clipped()
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Metrics.imageSize, height: Metrics.imageSize)
                    .cornerRadius(Metrics.imageRadius)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .lineLimit(2)
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}


/// Экран-заглушка, отображаемый, когда список избранных статей пуст или не найден по фильтрам.
struct EmptyFavoritesView: View {
    /// Флаг, указывающий, применены ли фильтры поиска/категории.
    let hasFilters: Bool
    /// Текущий язык интерфейса, используемый для локализации сообщений.
    let selectedLanguage: String
    /// Функция перевода строк по ключу для указанного языка.
    let getTranslation: (String, String) -> String
    
    private enum Metrics {
        static let spacing: CGFloat = 12
        static let iconSize: CGFloat = 40
    }
    
    /// Основное содержимое экрана-заглушки: иконка, сообщение и дополнительный текст при активных фильтрах.
    var body: some View {
        VStack(spacing: Metrics.spacing) {
            Image(systemName: "star.slash")
                .font(.system(size: Metrics.iconSize, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(hasFilters
                 ? getTranslation("Ничего не найдено", selectedLanguage)
                 : getTranslation("Нет избранного", selectedLanguage))
                .font(.headline)
                .foregroundColor(.secondary)
            
            if hasFilters {
                Text(getTranslation("Попробуйте другой запрос или категорию", selectedLanguage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DS.Spacing.section)
    }
}

// MARK: - CategoryFilterButton

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    
    private enum Metrics {
        static let spacing: CGFloat = 6
        static let cornerRadius: CGFloat = 20
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.spacing) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline)
            .padding(.horizontal, DS.Spacing.m)
            .padding(.vertical, DS.Spacing.s)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(Metrics.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}
