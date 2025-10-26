//
//  ThemeToggle.swift
//  InGermanyCMS
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI
import ArticleKit

/// Область применения переключателя темы
public enum ThemeToggleScope {
    case app
    case preview(Binding<PreviewAppearance>)
}

/// Универсальный переключатель темы в виде иконки солнце/луна
public struct ThemeToggle: View {
    let scope: ThemeToggleScope
    @EnvironmentObject private var appTheme: AppThemeManager
    
    public init(scope: ThemeToggleScope) {
        self.scope = scope
    }

    public var body: some View {
        Button(action: toggleTheme) {
            ThemeIconView(theme: currentTheme)
                .contentShape(Rectangle())
        }
        .buttonStyle(ThemeToggleButtonStyle())
        .accessibilityLabel("Switch theme")
        .accessibilityValue(accessibilityValue)
    }
    
    // MARK: - Private
    private var currentTheme: AppThemeManager.Theme {
        switch scope {
        case .app:
            return appTheme.current
        case .preview(let apBinding):
            switch apBinding.wrappedValue.colorScheme {
            case .some(.light): return .light
            case .some(.dark): return .dark
            default: return .system
            }
        }
    }
    
    private var accessibilityValue: String {
        switch currentTheme {
        case .light: return "Light mode"
        case .dark: return "Dark mode"
        case .system: return "Auto mode"
        }
    }
    
    private func toggleTheme() {
        switch scope {
        case .app:
            switch appTheme.current {
            case .system: appTheme.set(.light)
            case .light: appTheme.set(.dark)
            case .dark: appTheme.set(.system)
            }
            
        case .preview(let apBinding):
            var updated = apBinding.wrappedValue
            switch updated.colorScheme {
            case nil: updated.colorScheme = .light
            case .some(.light): updated.colorScheme = .dark
            case .some(.dark): updated.colorScheme = nil
            @unknown default: updated.colorScheme = .light
            }
            apBinding.wrappedValue = updated
        }
    }
}

// MARK: - Иконка темы с анимацией
private struct ThemeIconView: View {
    let theme: AppThemeManager.Theme
    
    var body: some View {
        ZStack {
            // Солнце (для light темы)
            Image(systemName: "sun.max.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.yellow)
                .opacity(theme == .light ? 1 : 0)
                .scaleEffect(theme == .light ? 1 : 0.5)
            
            // Луна (для dark темы)
            Image(systemName: "moon.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .opacity(theme == .dark ? 1 : 0)
                .scaleEffect(theme == .dark ? 1 : 0.5)
            
            // Авто (системная тема) - обе иконки
            if theme == .system {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.yellow)
                    .offset(x: -3, y: -2)
                
                Image(systemName: "moon.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .offset(x: 3, y: 2)
            }
        }
        .frame(width: 28, height: 28)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: theme)
    }
}

// MARK: - Стиль кнопки
private struct ThemeToggleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(configuration.isPressed ? 0.2 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
