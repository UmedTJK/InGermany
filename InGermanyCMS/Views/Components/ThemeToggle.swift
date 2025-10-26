//
//  ThemeToggle.swift
//  InGermanyCMS
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI
import ArticleKit // для AppThemeManager

/// Область применения переключателя темы
public enum ThemeToggleScope {
    case app
    case preview(Binding<PreviewAppearance>)
}

/// Универсальный переключатель темы (Auto / Light / Dark)
public struct ThemeToggle: View {
    let scope: ThemeToggleScope
    @EnvironmentObject private var appTheme: AppThemeManager

    public init(scope: ThemeToggleScope) {
        self.scope = scope
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(["Auto", "Light", "Dark"], id: \.self) { label in
                Button(label) {
                    withAnimation { applySelection(label) }
                }
                .buttonStyle(.bordered)
                .tint(isActive(label) ? .accentColor : .secondary.opacity(0.3))
            }
        }
        .accessibilityLabel("Theme toggle")
    }

    // MARK: - Actions
    private func applySelection(_ label: String) {
        switch scope {
        case .app:
            switch label {
            case "Light": appTheme.set(.light)
            case "Dark":  appTheme.set(.dark)
            default:      appTheme.set(.system)
            }

        case .preview(let apBinding):
            var updated = apBinding.wrappedValue
            switch label {
            case "Light": updated.colorScheme = .light
            case "Dark":  updated.colorScheme = .dark
            default:      updated.colorScheme = nil
            }
            apBinding.wrappedValue = updated
        }
    }

    // MARK: - Active state
    private func isActive(_ label: String) -> Bool {
        switch scope {
        case .app:
            switch appTheme.current {
            case .system: return label == "Auto"
            case .light:  return label == "Light"
            case .dark:   return label == "Dark"
            }

        case .preview(let apBinding):
            switch apBinding.wrappedValue.colorScheme {
            case nil:           return label == "Auto"
            case .some(.light): return label == "Light"
            case .some(.dark):  return label == "Dark"
            @unknown default:   return false
            }
        }
    }
}
