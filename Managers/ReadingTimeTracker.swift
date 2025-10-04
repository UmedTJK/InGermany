//
//  ReadingTimeTracker.swift
//  InGermany
//

import Foundation

/// Сессия чтения статьи.
/// Содержит идентификатор статьи, время начала, окончания и рассчитанную длительность.
struct ReadingSession: Codable {
    /// Идентификатор статьи.
    let articleId: String
    /// Время начала чтения.
    let startTime: Date
    /// Время окончания чтения (может быть `nil`, если сессия ещё активна).
    var endTime: Date?
    /// Длительность чтения в секундах (если завершена).
    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
}

/// Трекер времени чтения статей.
/// Хранит активные и завершённые сессии, вычисляет статистику.
@MainActor
final class ReadingTimeTracker: ObservableObject {
    /// Глобально доступный экземпляр трекера.
    static let shared = ReadingTimeTracker()
    
    /// Активные сессии чтения (ключ — `articleId`).
    @Published private(set) var activeSessions: [String: ReadingSession] = [:]
    /// Завершённые сессии чтения.
    @Published private(set) var completedSessions: [ReadingSession] = []
    
    private let key = "readingSessions"
    
    /// Приватный инициализатор. Загружает сохранённые завершённые сессии из `DefaultsStore`.
    private init() {
        if let saved: [ReadingSession] = DefaultsStore.load(key, as: [ReadingSession].self) {
            completedSessions = saved
        }
    }
    
    /// Начинает отслеживание чтения статьи.
    /// - Parameter articleId: Уникальный идентификатор статьи.
    func startSession(articleId: String) {
        let session = ReadingSession(articleId: articleId, startTime: Date())
        activeSessions[articleId] = session
    }
    
    /// Завершает отслеживание чтения статьи и сохраняет результат.
    /// - Parameter articleId: Уникальный идентификатор статьи.
    ///
    /// Сохраняется только если длительность чтения > 3 секунд.
    func endSession(articleId: String) {
        guard var session = activeSessions[articleId] else { return }
        session.endTime = Date()
        activeSessions.removeValue(forKey: articleId)
        
        if let duration = session.duration, duration > 3 {
            completedSessions.append(session)
            save()
        }
    }
    
    /// Возвращает общее время чтения всех статей (в минутах).
    func getTotalReadingTime() -> Int {
        let totalSeconds = completedSessions.compactMap { $0.duration }.reduce(0, +)
        return Int(totalSeconds / 60)
    }
    
    /// Возвращает общее время чтения всех статей (в секундах).
    func getTotalReadingTimeInSeconds() -> Int {
        Int(completedSessions.compactMap { $0.duration }.reduce(0, +))
    }
    
    /// Возвращает время чтения за последние `N` дней (в минутах).
    /// - Parameter days: Количество дней.
    func getReadingTimeForLast(days: Int) -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let recentSessions = completedSessions.filter { $0.startTime > cutoffDate }
        let totalSeconds = recentSessions.compactMap { $0.duration }.reduce(0, +)
        return Int(totalSeconds / 60)
    }
    
    /// Очищает историю завершённых сессий.
    func clearSessions() {
        completedSessions.removeAll()
        save()
    }
    
    /// Сохраняет завершённые сессии в `DefaultsStore`.
    private func save() {
        DefaultsStore.save(completedSessions, for: key)
    }
}
