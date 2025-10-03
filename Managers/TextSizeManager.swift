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
/// Использует DefaultsStore для сохранения и загрузки.
@MainActor
final class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()

    @Published private(set) var textSize: TextSize = .medium
    @Published var customScale: Double = 1.0 { // добавлено поле под ползунок
        didSet { saveCustomScale() }
    }

    private let key = "textSize"
    private let customKey = "customTextScale"

    private init() {
        if let saved: TextSize = DefaultsStore.load(key, as: TextSize.self) {
            textSize = saved
        }
        if let savedScale: Double = DefaultsStore.load(customKey, as: Double.self) {
            customScale = savedScale
        } else {
            customScale = textSize.scale
        }
    }

    func setTextSize(_ size: TextSize) {
        textSize = size
        customScale = size.scale
        save()
    }

    private func save() {
        DefaultsStore.save(textSize, for: key)
        DefaultsStore.save(customScale, for: customKey)
    }

    private func saveCustomScale() {
        DefaultsStore.save(customScale, for: customKey)
    }
}
