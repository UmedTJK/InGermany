//
//  CardImageStyle.swift
//  InGermany
//
//  Created by SUM TJK on 26.09.25.
//
//
//  CardImageStyle.swift
//  InGermany
//

import Foundation

enum CardImageStyle: String, CaseIterable, Identifiable {
    case allCorners      // скруглить все углы
    case bottomCorners   // скруглить только снизу
    case fullWidth       // фото во всю ширину, только нижние углы

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .allCorners: return "Все углы"
        case .bottomCorners: return "Снизу"
        case .fullWidth: return "Во всю ширину"
        }
    }
}

