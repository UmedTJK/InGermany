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

                if let category = viewModel.category {
                    CategoryBadge(
                        title: category.localizedName(for: selectedLanguage),
                        systemImage: category.icon,
                        backgroundHex: category.colorHex
                    )
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
                            TagChip(text: tag)
                        }
                    }
                }

                HStack {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(DS.Typography.meta)
                        StarRatingView(rating: $viewModel.rating)
                            .font(DS.Typography.meta)
                            .foregroundStyle(DS.Color.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: DS.Spacing.xs) {
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

private struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DS.Typography.chip)
            .foregroundStyle(DS.Color.textSecondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .frame(minHeight: 28)
            .background(DS.Color.secondarySurface)
            .cornerRadius(DS.Radius.chip)
            .accessibilityLabel(Text(text))
    }
}

private struct CategoryBadge: View {
    let title: String
    let systemImage: String
    let backgroundHex: String

    var body: some View {
        let bg = Color(hex: backgroundHex) ?? DS.Color.surface
        let fg: Color = Self.contrastForeground(for: backgroundHex)

        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: systemImage)
                .font(DS.Typography.meta)
            Text(title)
                .font(DS.Typography.badge)
        }
        .padding(DS.Spacing.s)
        .background(bg.opacity(0.85))
        .foregroundStyle(fg)
        .cornerRadius(DS.Radius.badge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
    }

    private static func contrastForeground(for hex: String) -> Color {
        // Prefer dark text on light backgrounds, light text on dark backgrounds.
        guard let uiColor = UIColor(hex: hex) else { return .white }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        // WCAG relative luminance approximation.
        func toLinear(_ c: CGFloat) -> CGFloat {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let rl = 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b)
        return rl > 0.55 ? .black : .white
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }

        // Support RGB (6) or ARGB (8)
        guard let value = UInt64(string, radix: 16) else { return nil }

        let a, r, g, b: UInt64
        switch string.count {
        case 6:
            a = 255
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        case 8:
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        default:
            return nil
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
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
