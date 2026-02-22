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
    private var didLoadFromStorage = false
    private var isLoadingFromStorage = false

    init(localizationManager: LocalizationManager = LocalizationManager()) {
        self.localizationManager = localizationManager
    }

    // MARK: - Bootstrap
    func bootstrap() async {
        await loadFromStorageIfNeeded()
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
    private let localizationManager: LocalizationManager

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
    // Async load from storage if needed
    func loadFromStorageIfNeeded() async {
        if didLoadFromStorage || isLoadingFromStorage { return }
        isLoadingFromStorage = true

        let storageKey = self.storageKey
        let sessionsKey = self.sessionsKey

        do {
            async let loadedHistory: [ReadingHistoryEntry] = DefaultsStore.loadAsync(storageKey, as: [ReadingHistoryEntry].self) ?? []
            async let loadedSessions: [ReadingSession] = DefaultsStore.loadAsync(sessionsKey, as: [ReadingSession].self) ?? []

            let (entries, sessions) = try await (loadedHistory, loadedSessions)

            // Publish on main actor (we are already @MainActor)
            self.history = entries.sorted { $0.readAt > $1.readAt }
            self.completedSessions = sessions

            self.didLoadFromStorage = true
        } catch {
            // Keep app functional; record the error for diagnostics.
            print("⚠️ [ReadingStatsManager] Failed to load reading stats from storage: \(error)")
            self.history = []
            self.completedSessions = []
            self.didLoadFromStorage = true
        }

        self.isLoadingFromStorage = false
    }

    // Synchronous wrappers kept for callers (if any). They just schedule async loading.
    private func loadHistory() {
        Task { [weak self] in
            await self?.loadFromStorageIfNeeded()
        }
    }

    private func saveHistory() {
        let snapshot = history
        Task(priority: .utility) {
            do {
                try await DefaultsStore.saveAsync(snapshot, for: storageKey)
            } catch {
                print("⚠️ [ReadingStatsManager] Failed to save history: \(error)")
            }
        }
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
        // Persist cleared state
        saveHistory()
        saveSessions()
        didLoadFromStorage = true
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
        Task { [weak self] in
            await self?.loadFromStorageIfNeeded()
        }
    }

    private func saveSessions() {
        let snapshot = completedSessions
        Task(priority: .utility) {
            do {
                try await DefaultsStore.saveAsync(snapshot, for: sessionsKey)
            } catch {
                print("⚠️ [ReadingStatsManager] Failed to save sessions: \(error)")
            }
        }
    }

    // MARK: - Helpers
    func estimateReadingTime(for text: String, language: String = "ru") -> Int {
        ReadingTimeCalculator.estimateReadingTime(for: text, language: language)
    }

    func formatReadingTime(_ minutes: Int, language: String = "ru") -> String {
        ReadingTimeCalculator.formatReadingTime(minutes, language: language)
    }

    func progressStatus(for progress: CGFloat, language: String) -> String {
        switch progress {
        case 0..<0.1: return localizationManager.getTranslation(key: "Начало", language: language)
        case 0.1..<0.7: return localizationManager.getTranslation(key: "В процессе", language: language)
        case 0.7..<0.99: return localizationManager.getTranslation(key: "Почти готово", language: language)
        default: return localizationManager.getTranslation(key: "Готово", language: language)
        }
    }
}
