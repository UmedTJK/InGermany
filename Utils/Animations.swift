//
//  Animations.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//
import SwiftUI

enum AppAnimations {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3)
    static let fade = Animation.easeInOut(duration: 0.3)
    static let smooth = Animation.easeInOut(duration: 0.4)
    static let bounce = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.95, blue: 0.97),
                                    Color(red: 0.98, green: 0.98, blue: 0.99)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.4), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

// Стиль для кнопки с использованием ваших анимаций
struct AppleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppAnimations.spring, value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.03 : 0)
    }
}
