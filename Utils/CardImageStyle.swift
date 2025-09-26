//
//  CardImageStyle.swift
//  InGermany
//
//  Created by SUM TJK on 26.09.25.
//

import Foundation

enum CardImageStyle: String, CaseIterable, Identifiable {
    case allCorners      // скруглить все углы
    case bottomCorners   // скруглить только снизу
    case fullWidth       // фото во всю ширину, только нижние углы

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .allCorners:
            return LocalizationManager.shared.getTranslation(key: "card_style_all",
                                                             language: LocalizationManager.shared.selectedLanguage)
        case .bottomCorners:
            return LocalizationManager.shared.getTranslation(key: "card_style_bottom",
                                                             language: LocalizationManager.shared.selectedLanguage)
        case .fullWidth:
            return LocalizationManager.shared.getTranslation(key: "card_style_full",
                                                             language: LocalizationManager.shared.selectedLanguage)
        }
    }
}
