//
//  Components.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

import SwiftUI

// MARK: - ToolCard

struct ToolCard: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(width: 120, height: 120)
        .background(Theme.backgroundCard)
        .cornerRadius(Theme.cardCornerRadius)
        .shadow(color: Theme.cardShadow.color,
                radius: Theme.cardShadow.radius,
                x: Theme.cardShadow.x,
                y: Theme.cardShadow.y)
    }
}



// MARK: - RecentArticleCard

struct RecentArticleCard: View {
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

            VStack(alignment: .leading, spacing: 4) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .lineLimit(2)
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}


// MARK: - EmptyFavoritesView

struct EmptyFavoritesView: View {
    let hasFilters: Bool
    let selectedLanguage: String
    let getTranslation: (String, String) -> String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(hasFilters
                 ? getTranslation("Ничего не найдено", selectedLanguage)
                 : getTranslation("Нет избранного", selectedLanguage))
                .font(.headline)
                .foregroundColor(.secondary)
            
            if hasFilters {
                Text(getTranslation("Попробуйте другой запрос или категорию", selectedLanguage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

// MARK: - CategoryFilterButton

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

