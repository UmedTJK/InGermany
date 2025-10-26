//
//  AppThemeModifier.swift
//  InGermany
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI

/// Модификатор, который применяет глобальную тему приложения
public struct AppThemeModifier: ViewModifier {
    // используем EnvironmentObject, но с защитой от отсутствия
    @EnvironmentObject private var appTheme: AppThemeManager

    public init() {}

    public func body(content: Content) -> some View {
        // безопасный доступ
        if let scheme = appTheme.current.colorScheme {
            content.preferredColorScheme(scheme)
        } else {
            content
        }
    }
}

public extension View {
    /// Применяет глобальную тему приложения, если `AppThemeManager` доступен
    @inlinable
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }
}
