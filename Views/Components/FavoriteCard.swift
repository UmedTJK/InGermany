//
//  FavoriteCard.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct FavoriteCard: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let article: Article                  // ВТОРОЙ параметр
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore
    
    var body: some View {
        let cardWidth = CardSize.width(for: UIScreen.main.bounds.width)
        let cardHeight = CardSize.height(
            for: UIScreen.main.bounds.height,
            screenWidth: UIScreen.main.bounds.width
        )
        
        VStack(alignment: .leading, spacing: 0) {
            // Верхний баннер = 60% от высоты карточки
            ZStack {
                Rectangle()
                    .fill(Theme.cardGradient)
                    .frame(height: cardHeight * 0.6)
                
                if let category = categoriesStore.category(for: article.categoryId) {
                    Image(systemName: category.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Нижний текстовый блок = 40% от высоты карточки
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(article.title[selectedLanguage] ?? article.title["ru"] ?? "")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(favoritesManager.isFavorite(article: article) ? .yellow : .gray.opacity(0.6))
                        .symbolEffect(.bounce, value: favoritesManager.isFavorite(article: article))
                }
                
                if let _ = categoriesStore.category(for: article.categoryId) {
                    Text(categoriesStore.categoryName(for: article.categoryId, language: selectedLanguage).uppercased())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.12))
                        )
                }
            }
            .padding(12)
            .frame(height: cardHeight * 0.4) // нижний блок = 40%
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(Theme.backgroundCard)
        .cornerRadius(Theme.cardCornerRadius)
        .shadow(color: Theme.cardShadow.color,
                radius: Theme.cardShadow.radius,
                x: Theme.cardShadow.x,
                y: Theme.cardShadow.y)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        FavoriteCard(
            favoritesManager: FavoritesManager(),
            article: Article.sampleArticle
        )
        .environmentObject(CategoriesStore.shared)
    }
}
