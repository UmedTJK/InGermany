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
                        .cornerRadius(12)
                case .bottomCorners, .fullWidth:
                    baseView
                        .frame(width: cardWidth, height: cardHeight * 0.55)
                        .clipped()
                        .cornerRadius(12, corners: UIRectCorner([.bottomLeft, .bottomRight]))
                }

                if let category = viewModel.category,
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

            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(viewModel.article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !viewModel.article.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(viewModel.article.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        StarRatingView(rating: $viewModel.rating)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(viewModel.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
        }
        .frame(width: cardWidth)
        .cardStyle() // ✅ вместо applyCardStyle(CardStyle...)
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

