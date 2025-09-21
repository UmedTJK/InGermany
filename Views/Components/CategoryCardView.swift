//
//  CategoryCardView.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

//
//  CategoryCardView.swift
//  InGermany
//

import SwiftUI

struct CategoryCardView: View {
    let category: Category
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        let cardWidth = CardSize.width(for: UIScreen.main.bounds.width) * 0.7
        let cardHeight = CardSize.height(
            for: UIScreen.main.bounds.height,
            screenWidth: UIScreen.main.bounds.width
        ) * 0.8

        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(Color(hex: category.colorHex) ?? .blue)
                    .frame(height: cardHeight * 0.6)

                Image(systemName: category.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(category.localizedName(for: selectedLanguage))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
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
    CategoryCardView(
        category: Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance"],
            icon: "banknote",
            colorHex: "#4A90E2"
        )
    )
}
