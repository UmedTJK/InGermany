//
//  ShimmerEffect.swift
//  InGermany
//
//  Created by SUM TJK on 11.10.25.
//

//
//  ShimmerEffect.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// ViewModifier для эффекта "shimmer" — анимированного скелетона загрузки.
/// Используется для отображения placeholder-контента при загрузке данных.
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.4),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase * 250)
                .blendMode(.overlay)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    /// Добавляет shimmer-анимацию к View.
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}
