//
//  Animations.swift
//  InGermany
//

import SwiftUI

// MARK: - View Modifiers
extension View {
    /// Applies the standard card style with background, corner radius, and shadow.
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(
                color: Theme.cardShadow.color,
                radius: Theme.cardShadow.radius,
                x: Theme.cardShadow.x,
                y: Theme.cardShadow.y
            )
    }
    
    /// Applies a card style with a lighter shadow effect.
    func lightCardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(
                color: Theme.lightShadow.color,
                radius: Theme.lightShadow.radius,
                x: Theme.lightShadow.x,
                y: Theme.lightShadow.y
            )
    }
    
    /// Adds a spring scale animation on view appearance.
    func scaleOnAppear() -> some View {
        self
            .scaleEffect(0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
    }
    
    /// Adds a press (tap down) animation.
    func pressAnimation() -> some View {
        self
            .scaleEffect(0.97)
            .animation(.easeInOut(duration: 0.2), value: UUID())
    }
    
    /// Adds a slide-in animation with optional delay.
    func slideInAnimation(delay: Double = 0) -> some View {
        self
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.3).delay(delay), value: UUID())
    }
}
