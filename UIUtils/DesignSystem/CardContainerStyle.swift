//
//  CardContainerStyle.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//

import SwiftUI

/// Canonical card container styles (single source of truth).
enum CardContainerVariant {
    /// Standard elevated surface. Use `useMaterial` when the card sits over imagery.
    case standard(useMaterial: Bool = false)
}

private struct CardContainerModifier: ViewModifier {
    let variant: CardContainerVariant

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        switch variant {
        case let .standard(useMaterial):
            content
                .background(backgroundView(useMaterial: useMaterial))
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
                .overlay(strokeOverlay)
        }
    }

    @ViewBuilder
    private func backgroundView(useMaterial: Bool) -> some View {
        if useMaterial {
            // Material reads as “premium glass” and avoids banding on complex backgrounds.
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .fill(DS.Elevation.card.material)
        } else {
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .fill(DS.Color.surface)
        }
    }

    private var strokeOverlay: some View {
        RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
            .stroke(
                DS.Elevation.card.strokeColor(for: colorScheme),
                lineWidth: DS.Elevation.card.strokeWidth
            )
    }
}

extension View {
    @ViewBuilder
    func cardContainer(_ variant: CardContainerVariant = .standard()) -> some View {
        self.modifier(CardContainerModifier(variant: variant))
    }
}

// MARK: - Card press feedback

private struct CardPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? DS.Interaction.pressScale : 1))
            .overlay(pressedStrokeOverlay(isPressed: configuration.isPressed))
            .shadow(
                color: DS.Elevation.card.keyShadowColor(for: colorScheme),
                radius: keyRadius(isPressed: configuration.isPressed),
                x: DS.Elevation.card.keyShadowX,
                y: DS.Elevation.card.keyShadowY
            )
            .shadow(
                color: DS.Elevation.card.ambientShadowColor(for: colorScheme),
                radius: ambientRadius(isPressed: configuration.isPressed),
                x: DS.Elevation.card.ambientShadowX,
                y: DS.Elevation.card.ambientShadowY
            )
            .animation(
                reduceMotion ? nil : .easeOut(duration: DS.Interaction.pressAnimationDuration),
                value: configuration.isPressed
            )
    }

    private func keyRadius(isPressed: Bool) -> CGFloat {
        isPressed ? DS.Elevation.card.keyShadowRadius * DS.Interaction.pressedShadowMultiplier : DS.Elevation.card.keyShadowRadius
    }

    private func ambientRadius(isPressed: Bool) -> CGFloat {
        isPressed ? DS.Elevation.card.ambientShadowRadius * DS.Interaction.pressedShadowMultiplier : DS.Elevation.card.ambientShadowRadius
    }

    @ViewBuilder
    private func pressedStrokeOverlay(isPressed: Bool) -> some View {
        if isPressed {
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .stroke(
                    DS.Elevation.card.strokeColor(for: colorScheme)
                        .opacity(1 + DS.Interaction.pressedStrokeOpacityBoost),
                    lineWidth: DS.Elevation.card.strokeWidth
                )
        }
    }
}

extension View {
    /// Adds subtle press feedback for interactive card surfaces. Use on the view inside a `Button { }`.
    func cardPressFeedback() -> some View {
        self.buttonStyle(CardPressStyle())
    }
}
