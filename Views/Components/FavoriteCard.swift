//
//  FavoriteCard.swift
//  InGermany
//

import SwiftUI

struct FavoriteCard: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        HStack(spacing: 12) {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
