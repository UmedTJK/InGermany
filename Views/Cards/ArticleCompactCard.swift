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
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(viewModel.article.localizedContent(for: selectedLanguage))
                    .font(DS.Typography.cardBody)
                    .foregroundStyle(DS.Color.textSecondary)
                    .lineLimit(2)
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
        .scaleOnAppear()
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
