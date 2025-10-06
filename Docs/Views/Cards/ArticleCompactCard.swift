//
//  ArticleCompactCard.swift
//  InGermany
//

import SwiftUI

/// A compact article card view for displaying an article with image, title, tags, rating, and reading progress.
struct ArticleCompactCard: View {
    /// The article model displayed in the card.
    let article: Article
    /// The image corner style preference loaded from AppStorage.
    @AppStorage("cardImageStyle") private var cardImageStyle: CardImageStyle = .bottomCorners
    /// The current language code for localization.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    /// Shared rating manager for handling article ratings.
    @StateObject private var ratingManager = RatingManager.shared
    /// Shared tracker for reading progress.
    @StateObject private var readingProgressTracker = ReadingProgressTracker.shared
    /// Repository for categories.
    @StateObject private var categoriesRepository = DefaultCategoriesRepository.shared
    
    /// The current screen size from Environment.
    @Environment(\.screenSize) private var screenSize
    
    /// Builds the UI for the article card with image, title, tags, rating, reading time, and progress.
    var body: some View {
        let cardWidth = CardSize.width(for: screenSize.width)
        let cardHeight = CardSize.height(for: screenSize.height, screenWidth: screenSize.width)
        
        VStack(alignment: .leading, spacing: 0) {
            // 📸 Изображение статьи (берётся из JSON → Resources/Images/)
            ZStack(alignment: .topLeading) {
                let baseView: some View = Group {
                    if let name = article.image,
                       let uiImage = UIImage(named: name, in: .main, with: nil) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .background(Color.secondary.opacity(0.08))
                    }
                }
                
                switch cardImageStyle {
                case .allCorners:
                    baseView
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(12)
                    
                case .bottomCorners:
                    baseView
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                    
                case .fullWidth:
                    baseView
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                }
                
                // 🏷 Категория
                if let category = categoriesRepository.category(by: article.categoryId),
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
            .frame(width: cardWidth)
            
            // 📄 Контент статьи
            VStack(alignment: .leading, spacing: 10) {
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
                        // Исправлено: используем Binding с get/set для рейтинга
                        StarRatingView(
                            rating: Binding(
                                get: { ratingManager.getRating(for: article.id) },
                                set: { newValue in ratingManager.setRating(newValue, for: article.id) }
                            )
                        )
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
            .padding(12)
        }
        .frame(width: cardWidth)
        .cardStyle()
        .scaleOnAppear()
    }
}

// MARK: - Экранный размер
/// Provides the screen size through the Environment.
private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}

// MARK: - CornerRadius только для выбранных углов
/// Allows applying corner radius to specific corners only.
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

/// Applies rounded corners selectively to specified corners.
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
