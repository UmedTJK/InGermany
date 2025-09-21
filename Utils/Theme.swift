
//  Theme.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import SwiftUI

struct Theme {
    // MARK: - Colors
    static let primaryBlue = Color.blue
    static let secondaryGray = Color.secondary
    static let backgroundCard = Color(.systemBackground)
    static let backgroundMain = Color(.systemGroupedBackground)
    
    // MARK: - Gradients
    static let cardGradient = LinearGradient(
        colors: [
            Color(red: 0.88, green: 0.91, blue: 0.96),
            Color(red: 0.78, green: 0.83, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let favoriteCardGradient = LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Spacing
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    static let smallPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    
    // MARK: - Shadows
    static let cardShadow = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    static let lightShadow = Shadow(
        color: Color.black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func sectionCardStyle() -> some View {
        self
            .padding(.vertical, 12)
            .background(Theme.backgroundCard)
            .cornerRadius(Theme.cardCornerRadius)
            .shadow(color: Theme.cardShadow.color,
                    radius: Theme.cardShadow.radius,
                    x: Theme.cardShadow.x,
                    y: Theme.cardShadow.y)
            .padding(.horizontal)
    }
}
