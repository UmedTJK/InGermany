//
//  ReadingProgressTracker.swift
//  InGermany
//

import SwiftUI

@MainActor
final class ReadingProgressTracker: ObservableObject {
    static let shared = ReadingProgressTracker()

    // Словарь: article.id → прогресс (0.0 ... 1.0)
    @Published private(set) var progress: [String: CGFloat] = [:]

    private init() {}

    /// Обновить прогресс
    func updateProgress(for articleID: String, value: CGFloat) {
        let clamped = min(max(value, 0), 1) // ограничиваем от 0 до 1
        progress[articleID] = clamped
    }

    /// Получить прогресс
    func progressForArticle(_ articleID: String) -> CGFloat {
        progress[articleID] ?? 0
    }

    /// Сбросить прогресс
    func reset(for articleID: String) {
        progress[articleID] = 0
    }
}
