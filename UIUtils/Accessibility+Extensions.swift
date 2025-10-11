//
//  Accessibility+Extensions.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// Расширения для удобного добавления доступности (VoiceOver).
extension View {
    /// Добавляет читаемую метку для VoiceOver
    func a11yLabel(_ text: String) -> some View {
        self.accessibilityLabel(Text(text))
    }

    /// Добавляет подсказку, которую VoiceOver озвучит
    func a11yHint(_ text: String) -> some View {
        self.accessibilityHint(Text(text))
    }

    /// Добавляет дополнительные атрибуты (например, "кнопка")
    func a11yAddTraits(_ traits: AccessibilityTraits) -> some View {
        self.accessibilityAddTraits(traits)
    }
}
