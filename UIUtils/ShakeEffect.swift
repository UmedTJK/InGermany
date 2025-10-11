//
//  ShakeEffect.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// Эффект "тряски" для View, например, при ошибке ввода.
/// Используется через .modifier(Shake(animatableData: CGFloat(errorCount))).
struct Shake: GeometryEffect {
    var amount: CGFloat = 10      // амплитуда тряски
    var shakesPerUnit = 3         // количество колебаний
    var animatableData: CGFloat   // триггер для анимации (обычно счётчик ошибок)

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}
