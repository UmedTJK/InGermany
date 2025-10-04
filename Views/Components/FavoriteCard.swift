//
//  FavoriteCard.swift
//  InGermany
//

import SwiftUI

/// Карточка избранной статьи с изображением, заголовком и кратким содержанием.
struct FavoriteCard: View {
    /// Модель статьи, отображаемая в карточке.
    let article: Article
    /// Выбранный язык интерфейса для локализации текста.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Основное содержимое карточки: изображение статьи, заголовок и краткий текст.
    var body: some View {
        HStack(spacing: 12) {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                /// Изображение статьи из ресурсов Bundle.
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                /// Запасное изображение по умолчанию.
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
