//
//  ReadingHistoryManager.swift
//  InGermany
//

import Foundation
import Combine

/// Запись о прочтении статьи
struct ReadingHistoryEntry: Codable, Identifiable {
    let id: UUID
    let articleId: String
    let date: Date
    
    init(articleId: String, date: Date = Date()) {
        self.id = UUID()
        self.articleId = articleId
        self.date = date
    }
}

/// Статистика по истории чтения
struct ReadingStats {
    let totalArticlesRead: Int
    let totalReadingTimeSeconds: Int
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

    /// Добавить новую запись в историю
    func addEntry(articleId: String) {
        let entry = ReadingHistoryEntry(articleId: articleId, date: Date())
        history.insert(entry, at: 0) // новые записи сверху
        save()
    }

    /// Очистить историю и время чтения
    func clearHistory() {
        history.removeAll()
        save()
        // синхронизируем с трекером времени
        ReadingTimeTracker.shared.clearSessions()
    }

    /// Получить статистику чтения
    func getStats() -> ReadingStats {
        let totalArticles = Set(history.map { $0.articleId }).count
        let totalSeconds = ReadingTimeTracker.shared.getTotalReadingTimeInSeconds()
        let streak = calculateStreak()
        
        return ReadingStats(
            totalArticlesRead: totalArticles,
            totalReadingTimeSeconds: totalSeconds,
            readingStreak: streak
        )
    }

    /// Вычисление серии подряд идущих дней чтения
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

    /// Получить список недавно прочитанных статей
    func recentlyReadArticles(from articles: [Article]) -> [Article] {
        let recentArticleIds = history.map { $0.articleId }
        return articles.filter { recentArticleIds.contains($0.id) }
    }
}
