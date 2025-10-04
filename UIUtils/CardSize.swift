//
//  CardSize.swift
//  InGermany
//
//  Created by Umed on 21.09.25.
//

import SwiftUI

/// Provides utility methods for calculating card dimensions based on screen size.
struct CardSize {
    /// Возвращает рекомендуемую ширину карточки в зависимости от ширины экрана.
    /// - Parameter screenWidth: Текущая ширина экрана.
    /// - Returns: Рассчитанная ширина карточки.
    static func width(for screenWidth: CGFloat) -> CGFloat {
        switch screenWidth {
        case 0..<380:   // маленькие iPhone (SE)
            return screenWidth * 0.65
        case 380..<500: // обычные и большие iPhone
            return screenWidth * 0.7
        default:        // iPad и шире
            return screenWidth * 0.75
        }
    }
    
    /// Возвращает рекомендуемую высоту карточки в зависимости от размеров экрана.
    /// - Parameters:
    ///   - screenHeight: Текущая высота экрана.
    ///   - screenWidth: Текущая ширина экрана.
    /// - Returns: Рассчитанная высота карточки.
    static func height(for screenHeight: CGFloat, screenWidth: CGFloat) -> CGFloat {
        switch screenWidth {
        case 0..<380:   // маленькие iPhone
            return screenHeight * 0.35
        case 380..<500: // обычные и большие iPhone
            return screenHeight * 0.4
        default:        // iPad и шире
            return screenHeight * 0.45
        }
    }
}
