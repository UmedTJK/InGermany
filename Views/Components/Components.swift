//
//  Components.swift
//  InGermany
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
        .shadow(
            color: Theme.cardShadow.color,
            radius: Theme.cardShadow.radius,
            x: Theme.cardShadow.x,
            y: Theme.cardShadow.y
        )
    }
}

// MARK: - EmptyFavoritesView

struct EmptyFavoritesView: View {
    let hasFilters: Bool
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text(
                hasFilters
                ? LocalizationManager.shared.translate("NoResults") // УБРАЛИ language параметр
                : LocalizationManager.shared.translate("NoFavorites") // УБРАЛИ language параметр
            )
            .font(.headline)
            .foregroundColor(.secondary)
            
            if hasFilters {
                Text(LocalizationManager.shared.translate("TryAnotherSearchOrCategory")) // УБРАЛИ language параметр
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
