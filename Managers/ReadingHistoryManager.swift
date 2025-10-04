//
//  ReadingHistoryManager.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import Foundation
import SwiftUI

/// Модель записи истории чтения статьи.
/// Хранит идентификатор, дату прочтения и время чтения в секундах.
struct ReadingHistoryEntry: Codable, Identifiable {
    /// Уникальный идентификатор записи.
    let id: String
    /// Идентификатор статьи.
    let articleId: String
    /// Дата прочтения.
    let readAt: Date
    /// Время чтения в секундах.
    let readingTimeSeconds: TimeInterval
    
    /// Создаёт новую запись для указанной статьи с текущей датой.
    /// - Parameters:
    ///   - articleId: Идентификатор статьи.
    ///   - readingTimeSeconds: Время чтения в секундах.
    init(articleId: String, readingTimeSeconds: TimeInterval) {
        self.id = UUID().uuidString
        self.articleId = articleId
        self.readAt = Date()
        self.readingTimeSeconds = readingTimeSeconds
    }
}

/// Менеджер для отслеживания истории чтения статей.
/// Сохраняет записи в `UserDefaults` и предоставляет статистику.
class ReadingHistoryManager: ObservableObject {
    /// Глобально доступный экземпляр менеджера.
    static let shared = ReadingHistoryManager()
    
    /// Список всех записей истории чтения (отсортирован по дате убыв.).
    @Published private(set) var history: [ReadingHistoryEntry] = []
    
    /// Хранение истории в `UserDefaults`.
    @AppStorage("readingHistory") private var storedHistory: Data = Data()
    
    /// Максимальное количество записей в истории.
    private let maxHistoryEntries = 100
    
    private init() {
        loadHistory()
    }
    
    /// Загружает историю из `UserDefaults`.
    private func loadHistory() {
        if let entries = try? JSONDecoder().decode([ReadingHistoryEntry].self, from: storedHistory) {
            history = entries.sorted { $0.readAt > $1.readAt }
        }
    }
    
    /// Сохраняет историю в `UserDefaults`.
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            storedHistory = data
        }
    }
    
    /// Добавляет запись о прочтении статьи.
    /// - Parameters:
    ///   - articleId: Идентификатор статьи.
    ///   - readingTime: Время чтения в секундах.
    func addReadingEntry(articleId: String, readingTime: TimeInterval) {
        // Удаляем предыдущие записи для этой статьи.
        history.removeAll { $0.articleId == articleId }
        
        let entry = ReadingHistoryEntry(articleId: articleId, readingTimeSeconds: readingTime)
        history.insert(entry, at: 0)
        
        // Ограничиваем размер истории.
        if history.count > maxHistoryEntries {
            history = Array(history.prefix(maxHistoryEntries))
        }
        
        saveHistory()
    }
    
    /// Возвращает последние прочитанные статьи.
    /// - Parameters:
    ///   - allArticles: Полный список статей.
    ///   - limit: Максимальное количество (по умолчанию 5).
    /// - Returns: Список последних прочитанных статей.
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article] {
        let recentIds = Array(history.prefix(limit).map { $0.articleId })
        return recentIds.compactMap { id in
            allArticles.first { $0.id == id }
        }
    }
    
    /// Проверяет, была ли статья прочитана.
    /// - Parameter articleId: Идентификатор статьи.
    /// - Returns: `true`, если статья есть в истории.
    func isRead(_ articleId: String) -> Bool {
        return history.contains { $0.articleId == articleId }
    }
    
    /// Возвращает дату последнего чтения статьи.
    /// - Parameter articleId: Идентификатор статьи.
    /// - Returns: Дата последнего чтения или `nil`.
    func lastReadDate(for articleId: String) -> Date? {
        return history.first { $0.articleId == articleId }?.readAt
    }
    
    /// Общее время чтения всех статей (в минутах).
    var totalReadingTimeMinutes: Int {
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        return Int(totalSeconds / 60)
    }
    
    /// Количество уникальных прочитанных статей.
    var totalArticlesRead: Int {
        return Set(history.map { $0.articleId }).count
    }
    
    /// Очищает историю чтения.
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    /// Возвращает агрегированную статистику чтения.
    func getStats() -> ReadingStats {
        return ReadingStats(from: history)
    }
}

// MARK: - Трекер времени чтения

/// Трекер для измерения времени чтения статьи в реальном времени.
/// Используется для фиксации длительности чтения.
class ReadingTracker: ObservableObject {
    private var startTime: Date?
    private var articleId: String?
    
    /// Начинает отслеживание чтения статьи.
    /// - Parameter articleId: Идентификатор статьи.
    func startReading(articleId: String) {
        self.articleId = articleId
        self.startTime = Date()
    }
    
    /// Завершает отслеживание и сохраняет результат в `ReadingHistoryManager`.
    /// Регистрирует только чтение дольше 10 секунд.
    func finishReading() {
        guard let startTime = startTime,
              let articleId = articleId else { return }
        
        let readingTime = Date().timeIntervalSince(startTime)
        
        if readingTime >= 10 {
            ReadingHistoryManager.shared.addReadingEntry(
                articleId: articleId,
                readingTime: readingTime
            )
        }
        
        self.startTime = nil
        self.articleId = nil
    }
    
    /// Текущее время чтения с момента запуска.
    var currentReadingTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Статистика чтения

/// Структура статистики чтения.
/// Содержит общее количество статей, время чтения и streak по дням.
struct ReadingStats {
    /// Количество уникальных прочитанных статей.
    let totalArticlesRead: Int
    /// Общее время чтения в минутах.
    let totalReadingTimeMinutes: Int
    /// Среднее время чтения на статью в минутах.
    let averageReadingTimeMinutes: Double
    /// Количество дней подряд с чтением.
    let readingStreak: Int
    
    /// Создаёт статистику из истории.
    /// - Parameter history: Список записей истории чтения.
    init(from history: [ReadingHistoryEntry]) {
        self.totalArticlesRead = Set(history.map { $0.articleId }).count
        
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        self.totalReadingTimeMinutes = Int(totalSeconds / 60)
        
        self.averageReadingTimeMinutes = totalArticlesRead > 0
            ? Double(totalReadingTimeMinutes) / Double(totalArticlesRead)
            : 0
        
        self.readingStreak = ReadingStats.calculateStreak(from: history)
    }
    
    /// Вычисляет streak (кол-во дней подряд с чтением, максимум 7).
    private static func calculateStreak(from history: [ReadingHistoryEntry]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        for i in 0..<7 {
            let hasReadingThisDay = history.contains { entry in
                calendar.isDate(entry.readAt, inSameDayAs: currentDate)
            }
            
            if hasReadingThisDay {
                streak += 1
            } else if i > 0 {
                break
            }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
}
