//
//  PreviewThemeManager.swift
//  InGermany
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI
import Combine

/// Менеджер локальной темы для предпросмотра (не влияет на глобальную тему macOS)
@MainActor
public final class PreviewThemeManager: ObservableObject {
    /// Текущее состояние предпросмотра
    @Published public var appearance: PreviewAppearance {
        didSet { persist() }
    }

    private let storageKey = "cms.preview.appearance"

    // MARK: - Init
    public init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(PreviewAppearance.self, from: data) {
            appearance = saved
        } else {
            appearance = .auto
        }
    }

    // MARK: - Быстрые пресеты
    public func auto()  { appearance = .auto }
    public func light() { appearance = .light }
    public func dark()  { appearance = .dark }

    public func setScheme(_ scheme: ColorScheme?) {
        appearance = PreviewAppearance(colorScheme: scheme,
                                       background: appearance.background)
    }

    public func setBackground(_ style: PreviewBackgroundStyle) {
        appearance = PreviewAppearance(colorScheme: appearance.colorScheme,
                                       background: style)
    }

    // MARK: - Persistence
    private func persist() {
        if let data = try? JSONEncoder().encode(appearance) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
