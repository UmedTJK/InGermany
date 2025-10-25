//
//  ThemeManager.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//

import Foundation
import SwiftUI
import Combine

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Theme Types
public enum AppTheme: String, CaseIterable, Codable {
    case system
    case light
    case dark
    
    public var displayName: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }
    
    public var iconName: String {
        switch self {
        case .system: return "circle.righthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

// MARK: - Color Scheme Extension
extension AppTheme {
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Theme Manager
@MainActor
public final class ThemeManager: ObservableObject {
    @Published public private(set) var currentTheme: AppTheme
    @Published public private(set) var effectiveColorScheme: ColorScheme
    
    private let userDefaultsKey = "selectedAppTheme"
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - Shared Instance
    public static let shared = ThemeManager()
    
    // MARK: - Initialization
    private init() {
        // 1. Определяем стартовую тему
        let initialTheme: AppTheme
        if let savedTheme = UserDefaults.standard.string(forKey: userDefaultsKey),
           let theme = AppTheme(rawValue: savedTheme) {
            initialTheme = theme
        } else {
            initialTheme = .system
        }
        
        // 2. Считаем стартовую цветовую схему через локальную переменную
        let initialColorScheme = Self.calculateEffectiveColorScheme(theme: initialTheme)
        
        // 3. Инициализируем все stored properties
        self.currentTheme = initialTheme
        self.effectiveColorScheme = initialColorScheme
        self.cancellables = []
        
        // 4. Теперь можно использовать self
        setupSystemThemeObservation()
    }
    
    // MARK: - Public Methods
    public func setTheme(_ theme: AppTheme) {
        guard theme != currentTheme else { return }
        
        currentTheme = theme
        effectiveColorScheme = Self.calculateEffectiveColorScheme(theme: theme)
        
        // Сохраняем выбор пользователя
        UserDefaults.standard.set(theme.rawValue, forKey: userDefaultsKey)
        
        print("🎨 Тема изменена: \(theme.displayName)")
        
        // Уведомляем об изменении темы (для macOS)
        #if os(macOS)
        updateAppearance()
        #endif
    }
    
    public func toggleTheme() {
        switch currentTheme {
        case .system:
            setTheme(.light)
        case .light:
            setTheme(.dark)
        case .dark:
            setTheme(.system)
        }
    }
    
    public func getNextTheme() -> AppTheme {
        switch currentTheme {
        case .system: return .light
        case .light: return .dark
        case .dark: return .system
        }
    }
    
    // MARK: - Theme Colors
    public struct Colors {
        public let background: Color
        public let secondaryBackground: Color
        public let tertiaryBackground: Color
        
        public let primaryText: Color
        public let secondaryText: Color
        public let tertiaryText: Color
        
        public let accent: Color
        public let accentSecondary: Color
        
        public let separator: Color
        public let border: Color
        public let shadow: Color
        
        public let success: Color
        public let warning: Color
        public let error: Color
        public let info: Color
    }
    
    public var colors: Colors {
        switch effectiveColorScheme {
        case .dark:
            return darkColors
        default:
            return lightColors
        }
    }
    
    // MARK: - Color Schemes
    private var lightColors: Colors {
        Colors(
            background: Color(NSColor.windowBackgroundColor),
            secondaryBackground: Color(NSColor.controlBackgroundColor),
            tertiaryBackground: Color(NSColor.textBackgroundColor),
            primaryText: Color(NSColor.textColor),
            secondaryText: Color(NSColor.secondaryLabelColor),
            tertiaryText: Color(NSColor.tertiaryLabelColor),
            accent: .accentColor,
            accentSecondary: Color(NSColor.systemBlue),
            separator: Color(NSColor.separatorColor),
            border: Color(NSColor.separatorColor),
            shadow: Color.black.opacity(0.1),
            success: Color(NSColor.systemGreen),
            warning: Color(NSColor.systemOrange),
            error: Color(NSColor.systemRed),
            info: Color(NSColor.systemBlue)
        )
    }
    
    private var darkColors: Colors {
        Colors(
            background: Color(NSColor.windowBackgroundColor),
            secondaryBackground: Color(NSColor.controlBackgroundColor),
            tertiaryBackground: Color(NSColor.textBackgroundColor),
            primaryText: Color(NSColor.textColor),
            secondaryText: Color(NSColor.secondaryLabelColor),
            tertiaryText: Color(NSColor.tertiaryLabelColor),
            accent: .accentColor,
            accentSecondary: Color(NSColor.systemBlue),
            separator: Color(NSColor.separatorColor),
            border: Color(NSColor.separatorColor),
            shadow: Color.black.opacity(0.3),
            success: Color(NSColor.systemGreen),
            warning: Color(NSColor.systemOrange),
            error: Color(NSColor.systemRed),
            info: Color(NSColor.systemBlue)
        )
    }
    
    // MARK: - Private Methods
    private func setupSystemThemeObservation() {
        #if os(macOS)
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                guard let self = self, self.currentTheme == .system else { return }
                self.effectiveColorScheme = Self.calculateEffectiveColorScheme(theme: .system)
            }
            .store(in: &cancellables)
        #endif
    }
    
    #if os(macOS)
    private func updateAppearance() {
        switch currentTheme {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            if #available(macOS 10.14, *) {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }
        }
    }
    #endif
    
    private static func calculateEffectiveColorScheme(theme: AppTheme) -> ColorScheme {
        switch theme {
        case .system:
            #if os(macOS)
            if #available(macOS 10.14, *) {
                return NSApp.effectiveAppearance.name == .darkAqua ? .dark : .light
            }
            #endif
            return .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Environment Values
extension EnvironmentValues {
    public var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
    
    private struct ThemeManagerKey: EnvironmentKey {
        static let defaultValue = ThemeManager.shared
    }
}

// MARK: - View Modifiers
extension View {
    public func withThemeManager() -> some View {
        environment(\.themeManager, ThemeManager.shared)
    }
}

// MARK: - Preview Support
#if DEBUG
extension ThemeManager {
    public static var preview: ThemeManager {
        let manager = ThemeManager.shared
        return manager
    }
}
#endif

// MARK: - Simple Theme Modifiers for ArticleKit
extension View {
    public func themeBackground(_ color: Color? = nil) -> some View {
        self.modifier(ThemeBackgroundModifier(color: color))
    }
    
    public func themeForeground(_ color: Color? = nil) -> some View {
        self.modifier(ThemeForegroundModifier(color: color))
    }
}

struct ThemeBackgroundModifier: ViewModifier {
    @Environment(\.themeManager) private var themeManager
    let color: Color?
    
    func body(content: Content) -> some View {
        content
            .background(color ?? themeManager.colors.background)
    }
}

struct ThemeForegroundModifier: ViewModifier {
    @Environment(\.themeManager) private var themeManager
    let color: Color?
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(color ?? themeManager.colors.primaryText)
    }
}
// MARK: - Theme Toggle Button
public struct ThemeToggleButton: View {
    @Environment(\.themeManager) private var themeManager
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            themeManager.toggleTheme()
        }) {
            Image(systemName: themeManager.currentTheme.iconName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.colors.primaryText)
        }
        .help("Переключить тему (\(themeManager.getNextTheme().displayName))")
        .keyboardShortcut("t", modifiers: .command)
    }
}

// MARK: - Quick Theme Menu
public struct QuickThemeMenu: View {
    @Environment(\.themeManager) private var themeManager
    
    public init() {}
    
    public var body: some View {
        Menu {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button {
                    themeManager.setTheme(theme)
                } label: {
                    HStack {
                        Image(systemName: theme.iconName)
                        Text(theme.displayName)
                        
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: themeManager.currentTheme.iconName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.colors.primaryText)
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .help("Выбор темы оформления")
    }
}
