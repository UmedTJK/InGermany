//
//  FavoriteCard.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct FavoriteCard: View {
    let article: Article
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let category = categoriesStore.category(for: article.categoryId) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.88, green: 0.91, blue: 0.96),
                                        Color(red: 0.78, green: 0.83, blue: 0.92)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(favoritesManager.isFavorite(article: article) ? .yellow : .gray.opacity(0.6))
                    .symbolEffect(.bounce, value: favoritesManager.isFavorite(article: article))
            }
            
            Text(article.title[selectedLanguage] ?? article.title["ru"] ?? "")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
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
        .padding(16)
        .frame(width: 170, height: 140)
        .cardStyle()
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        HStack {
            FavoriteCard(
                article: Article.sampleArticle,
                favoritesManager: FavoritesManager()
            )
            .environmentObject(CategoriesStore.shared)
            
            FavoriteCard(
                article: Article.sampleArticle,
                favoritesManager: FavoritesManager()
            )
            .environmentObject(CategoriesStore.shared)
        }
    }
}
