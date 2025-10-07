//
//  CardImageStyle.swift
//  InGermany
//
//  Created by SUM TJK on 26.09.25.
//

import Foundation

/// Определяет стили отображения изображений внутри карточек статей.
enum CardImageStyle: String, CaseIterable, Identifiable {
    /// Изображение с закруглёнными углами со всех сторон.
    case allCorners      // скруглить все углы
    /// Изображение с закруглёнными углами только снизу.
    case bottomCorners   // скруглить только снизу
    /// Изображение во всю ширину карточки, закруглены только нижние углы.
    case fullWidth       // фото во всю ширину, только нижние углы

    /// Уникальный идентификатор для использования в SwiftUI списках.
    var id: String { self.rawValue }

    /// Локализованное название стиля, используется в UI.
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

extension CardImageStyle {
    var localizedTitle: String {
        switch self {
        case .allCorners:
            return "Закругленные углы"
        case .bottomCorners:
            return "Закругленные снизу"
        case .fullWidth:
            return "На всю ширину"
        }
    }
}
