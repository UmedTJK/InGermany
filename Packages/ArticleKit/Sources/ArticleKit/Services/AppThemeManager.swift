//
//  AppThemeManager.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//

import SwiftUI
import Combine

@MainActor
public final class AppThemeManager: ObservableObject {
    public enum Theme: String, CaseIterable, Codable {
        case system, light, dark
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
        var title: String {
            switch self {
            case .system: return "Auto"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }

    @Published public private(set) var current: Theme {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: storageKey)
        }
    }

    private let storageKey = "app.theme.selection"

    public init() {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let saved = Theme(rawValue: raw) {
            current = saved
        } else {
            current = .system
        }
    }

    public func set(_ theme: Theme) {
        current = theme
    }
}
