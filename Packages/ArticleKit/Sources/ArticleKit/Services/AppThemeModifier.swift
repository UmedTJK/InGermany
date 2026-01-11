//
//  AppThemeModifier.swift
//  InGermany
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI

/// Модификатор, который применяет глобальную тему приложения
public struct AppThemeModifier: ViewModifier {
    // Используем Optional без @EnvironmentObject
    @Environment(\.appThemeManager) private var appTheme
    
    public init() {}
    
    public func body(content: Content) -> some View {
        // Безопасный доступ через optional binding
        if let theme = appTheme, let scheme = theme.current.colorScheme {
            content.preferredColorScheme(scheme)
        } else {
            content
        }
    }
}

// Создаем EnvironmentKey для безопасного доступа
private struct AppThemeManagerKey: EnvironmentKey {
    static let defaultValue: AppThemeManager? = nil
}

extension EnvironmentValues {
    var appThemeManager: AppThemeManager? {
        get { self[AppThemeManagerKey.self] }
        set { self[AppThemeManagerKey.self] = newValue }
    }
}

public extension View {
    /// Применяет глобальную тему приложения, если `AppThemeManager` доступен
    @inlinable
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }
    
    /// Устанавливает менеджер темы в окружение (альтернатива .environmentObject)
    func appThemeManager(_ manager: AppThemeManager) -> some View {
        environment(\.appThemeManager, manager)
    }
}
