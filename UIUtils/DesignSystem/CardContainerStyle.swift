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
                .shadow(
                    color: DS.Elevation.card.keyShadowColor(for: colorScheme),
                    radius: DS.Elevation.card.keyShadowRadius,
                    x: DS.Elevation.card.keyShadowX,
                    y: DS.Elevation.card.keyShadowY
                )
                .shadow(
                    color: DS.Elevation.card.ambientShadowColor(for: colorScheme),
                    radius: DS.Elevation.card.ambientShadowRadius,
                    x: DS.Elevation.card.ambientShadowX,
                    y: DS.Elevation.card.ambientShadowY
                )
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
