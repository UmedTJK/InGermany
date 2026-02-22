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
