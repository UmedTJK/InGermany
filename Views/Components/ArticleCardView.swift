//
//  ArticleCardView.swift
//  InGermany
//
//  Created by SUM TJK on 18.09.25.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let selectedLanguage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack {
                ForEach(article.tags.prefix(3), id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .shadow(radius: 2)
    }
}
