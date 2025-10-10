//
//  CardStyle.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
//
//  CardStyle.swift
//  InGermany
//
//  Created by AI Assistant on 10.10.25.
//

import SwiftUI

/// Defines available visual styles for article cards.
enum CardStyle: String, CaseIterable, Identifiable, Codable {
    case standard
    case light
    
    var id: String { rawValue }
    
    /// Localized title for settings UI
    var title: String {
        switch self {
        case .standard:
            return "Standard" // TODO: локализовать
        case .light:
            return "Light"    // TODO: локализовать
        }
    }
}

extension View {
    /// Applies a card style dynamically based on the provided `CardStyle`.
    func applyCardStyle(_ style: CardStyle) -> some View {
        switch style {
        case .standard:
            return AnyView(
                self
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(
                        color: Theme.cardShadow.color,
                        radius: Theme.cardShadow.radius,
                        x: Theme.cardShadow.x,
                        y: Theme.cardShadow.y
                    )
            )
        case .light:
            return AnyView(
                self
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(
                        color: Theme.lightShadow.color,
                        radius: Theme.lightShadow.radius,
                        x: Theme.lightShadow.x,
                        y: Theme.lightShadow.y
                    )
            )
        }
    }
}

