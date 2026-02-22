//
//  CardContainerStyle.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//
import SwiftUI

/// Canonical card container styles (single source of truth).
enum CardContainerVariant {
    case standard
}

extension View {
    @ViewBuilder
    func cardContainer(_ variant: CardContainerVariant = .standard) -> some View {
        switch variant {
        case .standard:
            self
                .background(DS.Color.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }
}
