//
//  ReadingHistoryManager.swift
//  InGermany
//

import Foundation
import Combine

/// Запись о прочтении статьи
struct ReadingHistoryEntry: Codable, Identifiable {
    let id = UUID()
    let articleId: String
    let date: Date
}

/// Статистика по истории чтения
struct ReadingStats {
    let totalArticlesRead: Int
    let totalReadingTimeMinutes: Int
    let readingStreak: Int
}

/// Менеджер истории прочтения статей.
/// Использует DefaultsStorage для сохранения и загрузки.
@MainActor
final class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()

    @Published private(set) var history: [ReadingHistoryEntry] = []

    private let key = "readingHistory"

    private init() {
        if let saved: [ReadingHistoryEntry] = DefaultsStorage.load(key, as: [ReadingHistoryEntry].self) {
            history = saved
        }
    }

    func addEntry(articleId: String) {
        let entry = ReadingHistoryEntry(articleId: articleId, date: Date())
        history.insert(entry, at: 0) // новые записи сверху
        save()
    }

    func clearHistory() {
        history.removeAll()
        save()
    }

    func getStats() -> ReadingStats {
        let totalArticles = history.count
        // Заглушка: пока просто считаем время = 3 минуты на статью
        let totalTime = totalArticles * 3
        let streak = calculateStreak()

        return ReadingStats(
            totalArticlesRead: totalArticles,
            totalReadingTimeMinutes: totalTime,
            readingStreak: streak
        )
    }

    private func calculateStreak() -> Int {
        guard !history.isEmpty else { return 0 }

        var streak = 1
        let calendar = Calendar.current

        for i in 1..<history.count {
            let prev = history[i - 1].date
            let curr = history[i].date
            if let diff = calendar.dateComponents([.day], from: curr, to: prev).day,
               diff == 1 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    private func save() {
        DefaultsStorage.save(history, for: key)
    }
}
