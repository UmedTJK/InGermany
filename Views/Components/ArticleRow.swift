//
//  ArticleRow.swift
//  InGermany
//

import SwiftUI

struct ArticleRow: View {
    @ObservedObject var viewModel: ArticleRowViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(viewModel.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !viewModel.metaInfo.isEmpty {
                    Text(viewModel.metaInfo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            // Favorite button
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
            
            // Rating (если используешь звёзды)
            StarRatingView(rating: $viewModel.rating)
                .frame(width: 100)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRow(viewModel: ArticleRowViewModel(article: Article.sampleArticle))
}
