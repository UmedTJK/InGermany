// ViewModels/ArticleRowViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class ArticleRowViewModel: ObservableObject {
    private let article: Article
    private let favoritesManager: FavoritesManager
    private let ratingManager: RatingManager

    @Published var isFavorite: Bool
    @Published var rating: Int

    init(article: Article,
         favoritesManager: FavoritesManager = .shared,
         ratingManager: RatingManager = .shared) {
        self.article = article
        self.favoritesManager = favoritesManager
        self.ratingManager = ratingManager

        self.isFavorite = favoritesManager.isFavorite(id: article.id)
        self.rating = ratingManager.getRating(for: article.id)
    }

    var title: String {
        article.localizedTitle
    }

    var subtitle: String {
        article.formattedReadingTime
    }

    var metaInfo: String {
        var parts: [String] = []
        if let createdAt = article.formattedCreatedDate {
            parts.append(createdAt)
        }
        if let updatedAt = article.formattedUpdatedDate {
            parts.append("Updated: \(updatedAt)")
        }
        return parts.joined(separator: " · ")
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(id: article.id)
        isFavorite = favoritesManager.isFavorite(id: article.id)
    }

    func setRating(_ newValue: Int) {
        ratingManager.setRating(newValue, for: article.id)
        rating = newValue
    }
}

// Views/Components/ArticleRow.swift
import SwiftUI

struct ArticleRow: View {
    @StateObject var viewModel: ArticleRowViewModel

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.headline)
                Text(viewModel.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(viewModel.metaInfo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                viewModel.toggleFavorite()
            }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? .red : .gray)
            }
            StarRatingView(rating: Binding(
                get: { viewModel.rating },
                set: { newValue in
                    viewModel.setRating(newValue)
                }
            ))
        }
        .padding(.vertical, 8)
    }
}
