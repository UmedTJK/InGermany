//
//  ReadingStatsManager.swift
//  InGermany
//
//  Created by SUM TJK on 09.10.25.
//
import SwiftUI
import Foundation

@MainActor
final class ReadingStatsManager: ObservableObject, ReadingStatsManagingProtocol {

    // MARK: - Internal State
    @Published private(set) var progress: [String: CGFloat] = [:]
    @Published private(set) var completedSessions: [ReadingSession] = []
    @Published private(set) var history: [ReadingHistoryEntry] = []

    private let storageKey = "readingHistory"
    private let sessionsKey = "readingSessions"
    private let maxHistoryEntries = 100

    init() {
        loadHistory()
        loadSessions()
    }

    // MARK: - Progress
    func updateProgress(for articleID: String, value: CGFloat) {
        let clamped = min(max(value, 0), 1)
        progress[articleID] = clamped
    }

    func progressForArticle(_ articleID: String) -> CGFloat {
        progress[articleID] ?? 0
    }

    func resetProgress(for articleID: String) {
        progress[articleID] = 0
    }

    // MARK: - Sessions
    private var activeSessions: [String: ReadingSession] = [:]

    func startSession(articleId: String) {
        let session = ReadingSession(articleId: articleId, startTime: Date())
        activeSessions[articleId] = session
    }

    func endSession(articleId: String) {
        guard var session = activeSessions[articleId] else { return }
        session.endTime = Date()
        activeSessions.removeValue(forKey: articleId)

        if let duration = session.duration, duration > 3 {
            completedSessions.append(session)
            saveSessions()
            addReadingEntry(articleId: articleId, readingTime: duration)
        }
    }

    func currentReadingTime(for articleId: String) -> TimeInterval {
        guard let session = activeSessions[articleId] else { return 0 }
        return Date().timeIntervalSince(session.startTime)
    }

    // MARK: - History
    private func loadHistory() {
        if let entries: [ReadingHistoryEntry] = DefaultsStore.load(storageKey, as: [ReadingHistoryEntry].self) {
            history = entries.sorted { $0.readAt > $1.readAt }
        }
    }

    private func saveHistory() {
        DefaultsStore.save(history, for: storageKey)
    }

    func addReadingEntry(articleId: String, readingTime: TimeInterval) {
        history.removeAll { $0.articleId == articleId }
        let entry = ReadingHistoryEntry(articleId: articleId, readingTimeSeconds: readingTime)
        history.insert(entry, at: 0)
        if history.count > maxHistoryEntries {
            history = Array(history.prefix(maxHistoryEntries))
        }
        saveHistory()
    }

    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article] {
        let recentIds = Array(history.prefix(limit).map { $0.articleId })
        return recentIds.compactMap { id in allArticles.first { $0.id == id } }
    }

    func isRead(_ articleId: String) -> Bool {
        history.contains { $0.articleId == articleId }
    }

    func lastReadDate(for articleId: String) -> Date? {
        history.first { $0.articleId == articleId }?.readAt
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
        completedSessions.removeAll()
        saveSessions()
        progress.removeAll()
    }

    // MARK: - Statistics
    var totalReadingTimeMinutes: Int {
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        return Int(totalSeconds / 60)
    }

    var totalArticlesRead: Int {
        Set(history.map { $0.articleId }).count
    }

    func getStats() -> ReadingStats {
        ReadingStats(from: history)
    }

    // MARK: - Sessions Persistence
    private func loadSessions() {
        if let saved: [ReadingSession] = DefaultsStore.load(sessionsKey, as: [ReadingSession].self) {
            completedSessions = saved
        }
    }

    private func saveSessions() {
        DefaultsStore.save(completedSessions, for: sessionsKey)
    }

    // MARK: - Helpers
    func estimateReadingTime(for text: String, language: String = "ru") -> Int {
        ReadingTimeCalculator.estimateReadingTime(for: text, language: language)
    }

    func formatReadingTime(_ minutes: Int, language: String = "ru") -> String {
        ReadingTimeCalculator.formatReadingTime(minutes, language: language)
    }

    func progressStatus(for progress: CGFloat, language: String) -> String {
        let lm = LocalizationManager.shared
        switch progress {
        case 0..<0.1: return lm.getTranslation(key: "Начало", language: language)
        case 0.1..<0.7: return lm.getTranslation(key: "В процессе", language: language)
        case 0.7..<0.99: return lm.getTranslation(key: "Почти готово", language: language)
        default: return lm.getTranslation(key: "Готово", language: language)
        }
    }
}

