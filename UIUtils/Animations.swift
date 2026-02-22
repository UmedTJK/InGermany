//
//  Animations.swift
//  InGermany
//

import SwiftUI

// MARK: - View Modifiers
extension View {
    /// Adds a spring scale-in on first appearance.
    /// Respects Reduce Motion (no scaling/animation when enabled).
    func scaleOnAppear() -> some View {
        modifier(ScaleOnAppearModifier())
    }

    /// Adds a press (tap down) scale effect.
    /// Respects Reduce Motion (no scaling/animation when enabled).
    func pressAnimation() -> some View {
        modifier(PressScaleModifier())
    }

    /// Provides a standard transition for views that are inserted/removed.
    /// Note: transition animation should be driven by the state change (e.g., `withAnimation`).
    /// Respects Reduce Motion by using a simple opacity transition.
    func slideInAnimation(delay: Double = 0) -> some View {
        modifier(SlideInTransitionModifier(delay: delay))
    }
}

private struct ScaleOnAppearModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.95))
            .onAppear { hasAppeared = true }
            .animation(
                reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6),
                value: hasAppeared
            )
    }
}

private struct PressScaleModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPressed ? 0.97 : 1.0))
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: 50,
                pressing: { isPressed = $0 },
                perform: {}
            )
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.2),
                value: isPressed
            )
    }
}

private struct SlideInTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double

    func body(content: Content) -> some View {
        content
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            .transaction { txn in
                // Disable implicit animations when Reduce Motion is enabled.
                if reduceMotion {
                    txn.animation = nil
                } else if txn.animation != nil {
                    txn.animation = txn.animation?.delay(delay)
                }
            }
    }
}
