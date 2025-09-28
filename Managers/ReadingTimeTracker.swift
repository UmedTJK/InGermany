//  ReadingTimeTracker.swift
//  InGermany
//

import Foundation

/// Сессия чтения статьи
struct ReadingSession: Codable {
    let articleId: String
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
}

/// Трекер времени чтения статей
@MainActor
final class ReadingTimeTracker: ObservableObject {
    static let shared = ReadingTimeTracker()
    
    @Published private(set) var activeSessions: [String: ReadingSession] = [:]
    @Published private(set) var completedSessions: [ReadingSession] = []
    
    private let key = "readingSessions"
    
    private init() {
        // Загружаем завершённые сессии
        if let saved: [ReadingSession] = DefaultsStorage.load(key, as: [ReadingSession].self) {
            completedSessions = saved
        }
    }
    
    /// Начать отслеживание чтения статьи
    func startSession(articleId: String) {
        let session = ReadingSession(articleId: articleId, startTime: Date())
        activeSessions[articleId] = session
    }
    
    /// Завершить отслеживание чтения статьи
    func endSession(articleId: String) {
        guard var session = activeSessions[articleId] else { return }
        session.endTime = Date()
        activeSessions.removeValue(forKey: articleId)
        
        // Сохраняем только сессии длительностью более 3 секунд
        if let duration = session.duration, duration > 3 {
            completedSessions.append(session)
            save()
        }
    }
    
    /// Получить общее время чтения всех статей (в минутах)
    func getTotalReadingTime() -> Int {
        let totalSeconds = completedSessions.compactMap { $0.duration }.reduce(0, +)
        return Int(totalSeconds / 60)
    }
    
    /// Получить общее время чтения всех статей (в секундах)
    func getTotalReadingTimeInSeconds() -> Int {
        Int(completedSessions.compactMap { $0.duration }.reduce(0, +))
    }
    
    /// Получить время чтения за последние N дней
    func getReadingTimeForLast(days: Int) -> Int {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let recentSessions = completedSessions.filter { $0.startTime > cutoffDate }
        let totalSeconds = recentSessions.compactMap { $0.duration }.reduce(0, +)
        return Int(totalSeconds / 60)
    }
    
    /// Очистить историю сессий
    func clearSessions() {
        completedSessions.removeAll()
        save()
    }
    
    private func save() {
        DefaultsStorage.save(completedSessions, for: key)
    }
}
