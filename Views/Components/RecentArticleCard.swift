//
//  RecentArticleCard.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//
//
//  RecentArticleCard.swift
//  InGermany
//

import SwiftUI

struct RecentArticleCard: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let article: Article                  // ВТОРОЙ параметр
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("Logo")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(article.formattedReadingTime(for: selectedLanguage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .frame(
            width: CardSize.width(for: UIScreen.main.bounds.width),
            height: CardSize.height(
                for: UIScreen.main.bounds.height,
                screenWidth: UIScreen.main.bounds.width
            )
        )
        .background(Theme.backgroundCard)
        .cornerRadius(Theme.cardCornerRadius)
        .shadow(
            color: Theme.cardShadow.color,
            radius: Theme.cardShadow.radius,
            x: Theme.cardShadow.x,
            y: Theme.cardShadow.y
        )
    }
}

#Preview {
    RecentArticleCard(
        favoritesManager: FavoritesManager(),
        article: Article.example
    )
}
