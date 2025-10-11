//
//  ArticleRow.swift
//  InGermany
//

import SwiftUI

/// Строка статьи, отображающая изображение, заголовок, метаданные, рейтинг и кнопку избранного.
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
                Image("Logo")
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
                
                HStack {
                    StarRatingView(
                        rating: Binding(
                            get: { viewModel.rating },
                            set: { newRating in
                                viewModel.setRating(newRating)
                            }
                        )
                    )
                    .frame(width: 100, alignment: .leading)
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.toggleFavorite()
            }) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let container = AppContainer.previewMock()
    let vm = container.makeArticleRowViewModel(article: Article.sampleArticles[0])
    ArticleRow(viewModel: vm)
        .environmentObject(container)
}
