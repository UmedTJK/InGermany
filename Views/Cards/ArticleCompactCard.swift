//
//  ArticleCompactCard.swift
//  InGermany
//

import SwiftUI

struct ArticleCompactCard: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject private var ratingManager = RatingManager.shared
    @ObservedObject private var readingProgressTracker = ReadingProgressTracker.shared
    @EnvironmentObject private var categoriesStore: CategoriesStore
    
    @Environment(\.screenSize) private var screenSize
    
    var body: some View {
        let cardWidth = CardSize.width(for: screenSize.width)
        let cardHeight = CardSize.height(for: screenSize.height, screenWidth: screenSize.width)
        
        VStack(alignment: .leading, spacing: 10) {
            // 📸 Изображение статьи
            ZStack(alignment: .topLeading) {
                if let name = article.image,
                   let uiImage = UIImage(named: name, in: .main, with: nil) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(12)
                }
                
                // 🏷 Категория
                if let category = categoriesStore.byId[article.categoryId],
                   let color = Color(hex: category.colorHex) {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.caption)
                        Text(category.localizedName(for: selectedLanguage))
                            .font(.caption2)
                            .bold()
                    }
                    .padding(6)
                    .background(color.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(8)
                }
            }
            
            // 📰 Заголовок
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // 📝 Анонс
            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // 🔖 Теги
            if !article.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(article.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
            
            // ⭐ Рейтинг + ⏱ Время чтения
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(ratingManager.rating(for: article.id))/5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 📊 Прогресс чтения
            let progress = readingProgressTracker.progressForArticle(article.id)
            if progress > 0 {
                ProgressBar(value: progress)
                    .frame(height: 4)
                    .padding(.top, 4)
            }
        }
        .frame(width: cardWidth)
        .padding(12)
        .cardStyle()
        .scaleOnAppear()
    }
}

// MARK: - Экранный размер (EnvironmentKey)
private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}
