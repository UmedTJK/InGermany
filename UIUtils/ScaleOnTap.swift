//
//  ScaleOnTap.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// ViewModifier, который добавляет анимацию уменьшения при нажатии.
/// Создаёт эффект "нажатой" кнопки или карточки.
struct ScaleOnTap: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

extension View {
    /// Применяет эффект "scale on tap" для имитации нажатия.
    func scaleOnTap() -> some View {
        self.modifier(ScaleOnTap())
    }
}
