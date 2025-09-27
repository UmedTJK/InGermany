//
//  TextSizeManager.swift
//  InGermany
//

import Foundation
import Combine

/// Размер текста в приложении
enum TextSize: String, Codable, CaseIterable {
    case small, medium, large

    var scale: Double {
        switch self {
        case .small: return 0.85
        case .medium: return 1.0
        case .large: return 1.25
        }
    }
}

/// Менеджер для хранения и управления размером текста.
/// Использует DefaultsStorage для сохранения и загрузки.
@MainActor
final class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()

    @Published private(set) var textSize: TextSize = .medium

    private let key = "textSize"

    private init() {
        if let saved: TextSize = DefaultsStorage.load(key, as: TextSize.self) {
            textSize = saved
        }
    }

    func setTextSize(_ size: TextSize) {
        textSize = size
        save()
    }

    private func save() {
        DefaultsStorage.save(textSize, for: key)
    }
}
