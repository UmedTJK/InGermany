//  Theme.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import SwiftUI

/// Defines the app-wide style constants such as colors, gradients, spacing, and shadows.
struct Theme {
    // MARK: - Colors
    /// Primary brand blue color.
    static let primaryBlue = Color.blue
    /// Secondary gray color for text and icons.
    static let secondaryGray = Color.secondary
    /// Background color used for cards.
    static let backgroundCard = Color(.systemBackground)
    /// Main background color for grouped content.
    static let backgroundMain = Color(.systemGroupedBackground)
    
    // MARK: - Gradients
    /// Gradient used for card backgrounds.
    static let cardGradient = LinearGradient(
        colors: [
            Color(red: 0.88, green: 0.91, blue: 0.96),
            Color(red: 0.78, green: 0.83, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Gradient used for favorite card backgrounds.
    static let favoriteCardGradient = LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Spacing
    /// Standard padding used inside cards.
    static let cardPadding: CGFloat = 16
    /// Corner radius applied to cards.
    static let cardCornerRadius: CGFloat = 12
    /// Small padding size.
    static let smallPadding: CGFloat = 8
    /// Medium padding size.
    static let mediumPadding: CGFloat = 16
    /// Large padding size.
    static let largePadding: CGFloat = 24
    
    // MARK: - Shadows
    /// Shadow style applied to cards.
    static let cardShadow = Shadow(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    /// Light shadow style for subtle depth.
    static let lightShadow = Shadow(
        color: Color.black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )
}

/// Defines a shadow style with color, radius, and offsets.
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    /// Applies a standard card style with padding, background, corner radius, and shadow.
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
