//
//  ArticleRow.swift
//  InGermany
//

import SwiftUI

struct ArticleRow: View {
    @ObservedObject var viewModel: ArticleRowViewModel
    
    var body: some View {
        let _ = {
            if let name = viewModel.imageName {
                print("🖼 ImageName:", name)
                print("📂 Bundle path:", Bundle.main.path(forResource: name, ofType: nil) ?? "Not found")
            } else {
                print("🚫 No image for article:", viewModel.title)
            }
        }()
        HStack {
            if let imageName = viewModel.imageName,
               let uiImage = UIImage(named: imageName, in: .main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Image("Logo") // запасной вариант
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            }
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
                
                // Rating под датой публикации, с выравниванием по тексту
                HStack {
                    StarRatingView(rating: $viewModel.rating)
                        .frame(width: 100, alignment: .leading)
                }
                .padding(.top, 2)
            }
            Spacer()
            
            // Favorite button
            Button(action: { viewModel.toggleFavorite() }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArticleRow(viewModel: ArticleRowViewModel(article: Article.sampleArticle))
}
