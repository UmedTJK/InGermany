//
//  Animations.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import SwiftUI

/// Provides reusable animation and style utilities for SwiftUI views and buttons.

// MARK: - View Modifiers
extension View {
    /// Applies the standard card style with background, corner radius, and shadow.
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Theme.cardCornerRadius)
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
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: UUID())
    }
    
    /// Adds a quick scale animation on press.
    func pressAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: UUID())
    }
}

// MARK: - Button Styles
/// Button style that mimics Apple's card button with scale and opacity changes on press.
struct AppleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Button style that scales the button when pressed, customizable scale factor.
struct ScaleButtonStyle: ButtonStyle {
    let scale: CGFloat
    
    init(scale: CGFloat = 0.95) {
        self.scale = scale
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Custom Animations
/// ViewModifier that applies a slide-in animation with a configurable delay.
struct SlideInAnimation: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : 50)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Applies a slide-in animation with an optional delay.
    func slideInAnimation(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(delay: delay))
    }
}

// MARK: - Loading States
/// A view showing animated dots as a loading indicator.
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Effect
/// ViewModifier that applies a shimmering effect over the content.
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .onAppear {
                        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                            phase = 300
                        }
                    }
            )
            .clipped()
    }
}

extension View {
    /// Applies a shimmering animation effect to the view.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Transition Effects
extension AnyTransition {
    /// Transition combining slide from trailing edge and fade on insertion, and slide to leading edge and fade on removal.
    static let slideAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    /// Transition combining scale and fade effects.
    static let scaleAndFade = AnyTransition.scale.combined(with: .opacity)
}

// MARK: - Haptic Feedback
/// Provides static methods for triggering different types of haptic feedback.
struct HapticFeedback {
    /// Triggers a light impact haptic feedback.
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Triggers a medium impact haptic feedback.
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Triggers a heavy impact haptic feedback.
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    /// Triggers a success notification haptic feedback.
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Triggers an error notification haptic feedback.
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Triggers a warning notification haptic feedback.
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}
