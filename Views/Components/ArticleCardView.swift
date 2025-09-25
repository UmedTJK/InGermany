//
//  ArticleCardView.swift
//  InGermany
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(12)
            }
            
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.headline)
                .lineLimit(2)
            
            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
