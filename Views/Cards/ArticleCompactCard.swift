//
//  ArticleCompactCard.swift
//  InGermany
//

import SwiftUI

/// A compact article card view using DI and ViewModel for displaying an article summary.
struct ArticleCompactCard: View {
    @ObservedObject var viewModel: ArticleRowViewModel
    
    @AppStorage("cardImageStyle") private var cardImageStyle: CardImageStyle = .bottomCorners
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @Environment(\.screenSize) private var screenSize
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let cardWidth = CardSize.width(for: screenSize.width)
        let cardHeight = CardSize.height(for: screenSize.height, screenWidth: screenSize.width)

        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                let baseView: some View = Group {
                    if let name = viewModel.article.image,
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
                        .cornerRadius(DS.Radius.media)
                case .bottomCorners, .fullWidth:
                    baseView
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(DS.Radius.media, corners: UIRectCorner([.bottomLeft, .bottomRight]))
                }

                if let category = viewModel.category,
                   let color = Color(hex: category.colorHex) {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: category.icon)
                            .font(DS.Typography.meta)
                        Text(category.localizedName(for: selectedLanguage))
                            .font(DS.Typography.badge)
                            .bold()
                    }
                    .padding(DS.Spacing.s)
                    .background(color.opacity(0.85))
                    .foregroundStyle(.white)
                    .cornerRadius(DS.Radius.badge)
                    .padding(DS.Spacing.s)
                }
            }
            .frame(width: cardWidth)

            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text(viewModel.article.localizedTitle(for: selectedLanguage))
                    .font(DS.Typography.cardTitle)
                    .foregroundStyle(DS.Color.textPrimary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .multilineTextAlignment(.leading)

                Text(viewModel.article.localizedContent(for: selectedLanguage))
                    .font(DS.Typography.cardBody)
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                    .multilineTextAlignment(.leading)

                if !viewModel.article.tags.isEmpty {
                    HStack(spacing: DS.Spacing.xs) {
                        ForEach(viewModel.article.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(DS.Typography.chip)
                                .padding(.horizontal, DS.Spacing.s)
                                .padding(.vertical, DS.Spacing.xs)
                                .background(DS.Color.secondarySurface)
                                .cornerRadius(DS.Radius.chip)
                        }
                    }
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(DS.Typography.meta)
                        StarRatingView(rating: $viewModel.rating)
                            .font(DS.Typography.meta)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundStyle(DS.Color.textSecondary)
                            .font(DS.Typography.meta)
                        Text(viewModel.subtitle)
                            .font(DS.Typography.meta)
                            .foregroundStyle(DS.Color.textSecondary)
                    }
                }
            }
            .padding(DS.Spacing.m)
        }
        .frame(width: cardWidth)
        .cardContainer()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .scaleOnAppear()
    }
    
    private var accessibilityLabel: Text {
        let title = viewModel.article.localizedTitle(for: selectedLanguage)
        if let category = viewModel.category {
            let cat = category.localizedName(for: selectedLanguage)
            return Text("\(title). \(localizedCategoryPrefix) \(cat).")
        } else {
            return Text(title)
        }
    }

    private var accessibilityValue: Text {
        // Use rating + subtitle (e.g., reading time).
        // Rating is typically 0...5. We announce it as "X of 5".
        let ratingClamped = max(0, min(5, viewModel.rating))
        let ratingText = "\(localizedRatingPrefix) \(ratingClamped) \(localizedOfFive)"
        let timeText = "\(localizedTimePrefix) \(viewModel.subtitle)"
        return Text("\(ratingText). \(timeText).")
    }

    private var accessibilityHint: Text {
        Text(localizedOpenHint)
    }

    private var localizedCategoryPrefix: String {
        switch selectedLanguage {
        case "ru": return "Категория:"
        case "de": return "Kategorie:"
        case "en": return "Category:"
        case "fa": return "دسته‌بندی:"
        case "tj": return "Категория:"
        case "ar": return "الفئة:"
        case "uk": return "Категорія:"
        default: return "Category:"
        }
    }

    private var localizedRatingPrefix: String {
        switch selectedLanguage {
        case "ru": return "Рейтинг"
        case "de": return "Bewertung"
        case "en": return "Rating"
        case "fa": return "امتیاز"
        case "tj": return "Рейтинг"
        case "ar": return "التقييم"
        case "uk": return "Рейтинг"
        default: return "Rating"
        }
    }

    private var localizedTimePrefix: String {
        switch selectedLanguage {
        case "ru": return "Время"
        case "de": return "Zeit"
        case "en": return "Time"
        case "fa": return "زمان"
        case "tj": return "Вақт"
        case "ar": return "الوقت"
        case "uk": return "Час"
        default: return "Time"
        }
    }

    private var localizedOfFive: String {
        switch selectedLanguage {
        case "ru": return "из 5"
        case "de": return "von 5"
        case "en": return "of 5"
        case "fa": return "از ۵"
        case "tj": return "аз 5"
        case "ar": return "من 5"
        case "uk": return "з 5"
        default: return "of 5"
        }
    }

    private var localizedOpenHint: String {
        switch selectedLanguage {
        case "ru": return "Дважды нажмите, чтобы открыть статью."
        case "de": return "Doppeltippen, um den Artikel zu öffnen."
        case "en": return "Double-tap to open the article."
        case "fa": return "برای باز کردن مقاله دوبار ضربه بزنید."
        case "tj": return "Барои кушодани мақола ду бор пахш кунед."
        case "ar": return "انقر مرتين لفتح المقال."
        case "uk": return "Двічі торкніться, щоб відкрити статтю."
        default: return "Double-tap to open the article."
        }
    }
}

#if DEBUG
#Preview {
    let container = AppContainer.previewMock()
    let vm = container.makeArticleRowViewModel(article: Article.sampleArticles[0])
    ArticleCompactCard(viewModel: vm)
        .environmentObject(container)
}
#endif
