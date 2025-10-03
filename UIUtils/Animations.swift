//
//  Animations.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import SwiftUI

// MARK: - View Modifiers
extension View {
    /// Применяет стандартный стиль карточки
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
    
    /// Применяет стиль карточки с легкой тенью
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
    
    /// Анимация появления с масштабированием
    func scaleOnAppear() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: UUID())
    }
    
    /// Анимация нажатия
    func pressAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: UUID())
    }
}

// MARK: - Button Styles
struct AppleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

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
    func slideInAnimation(delay: Double = 0) -> some View {
        modifier(SlideInAnimation(delay: delay))
    }
}

// MARK: - Loading States
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
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Transition Effects
extension AnyTransition {
    static let slideAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let scaleAndFade = AnyTransition.scale.combined(with: .opacity)
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func light() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func medium() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    static func heavy() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    static func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    static func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}
