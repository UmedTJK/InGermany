//
//  ArticleCardView.swift
//  InGermany
//

import SwiftUI

/// Карточка статьи с изображением, заголовком, рейтингом и кратким содержанием.
struct ArticleCardView: View {
    /// Модель статьи, отображаемая в карточке.
    let article: Article
    /// Выбранный язык интерфейса для локализации заголовка и содержимого.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    /// Менеджер рейтингов статей (используется для отображения и изменения рейтинга).
    @ObservedObject private var ratingManager = RatingManager.shared

    /// Основное содержимое карточки: изображение, заголовок, рейтинг и краткий текст статьи.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
            }
            
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.headline)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                StarRatingView(
                    rating: Binding(
                        get: { ratingManager.getRating(for: article.id) },
                        set: { newValue in ratingManager.setRating(newValue, for: article.id) }
                    )
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
