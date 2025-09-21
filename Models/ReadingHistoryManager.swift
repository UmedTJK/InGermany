//
//  ReadingHistoryManager.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import Foundation
import SwiftUI

/// Модель записи истории чтения
struct ReadingHistoryEntry: Codable, Identifiable {
    let id: String
    let articleId: String
    let readAt: Date
    let readingTimeSeconds: TimeInterval
    
    init(articleId: String, readingTimeSeconds: TimeInterval) {
        self.id = UUID().uuidString
        self.articleId = articleId
        self.readAt = Date()
        self.readingTimeSeconds = readingTimeSeconds
    }
}

/// Менеджер для отслеживания истории чтения статей
class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()
    
    @Published private(set) var history: [ReadingHistoryEntry] = []
    @AppStorage("readingHistory") private var storedHistory: Data = Data()
    
    // Максимальное количество записей в истории
    private let maxHistoryEntries = 100
    
    private init() {
        loadHistory()
    }
    
    /// Загружает историю из UserDefaults
    private func loadHistory() {
        if let entries = try? JSONDecoder().decode([ReadingHistoryEntry].self, from: storedHistory) {
            history = entries.sorted { $0.readAt > $1.readAt }
        }
    }
    
    /// Сохраняет историю в UserDefaults
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            storedHistory = data
        }
    }
    
    /// Добавляет запись о прочтении статьи
    /// - Parameters:
    ///   - articleId: ID статьи
    ///   - readingTime: Время чтения в секундах
    func addReadingEntry(articleId: String, readingTime: TimeInterval) {
        // Удаляем старые записи для той же статьи (оставляем только последнюю)
        history.removeAll { $0.articleId == articleId }
        
        let entry = ReadingHistoryEntry(articleId: articleId, readingTimeSeconds: readingTime)
        history.insert(entry, at: 0)
        
        // Ограничиваем размер истории
        if history.count > maxHistoryEntries {
            history = Array(history.prefix(maxHistoryEntries))
        }
        
        saveHistory()
    }
    
    /// Возвращает последние прочитанные статьи
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article] {
        let recentIds = Array(history.prefix(limit).map { $0.articleId })
        return recentIds.compactMap { id in
            allArticles.first { $0.id == id }
        }
    }
    
    /// Проверяет, была ли статья прочитана
    func isRead(_ articleId: String) -> Bool {
        return history.contains { $0.articleId == articleId }
    }
    
    /// Возвращает время последнего чтения статьи
    func lastReadDate(for articleId: String) -> Date? {
        return history.first { $0.articleId == articleId }?.readAt
    }
    
    /// Возвращает общее время чтения всех статей (в минутах)
    var totalReadingTimeMinutes: Int {
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        return Int(totalSeconds / 60)
    }
    
    /// Возвращает количество прочитанных статей
    var totalArticlesRead: Int {
        return Set(history.map { $0.articleId }).count
    }
    
    /// Очищает историю чтения
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
}

// MARK: - Трекер времени чтения
class ReadingTracker: ObservableObject {
    private var startTime: Date?
    private var articleId: String?
    
    /// Начинает отслеживание чтения статьи
    func startReading(articleId: String) {
        self.articleId = articleId
        self.startTime = Date()
    }
    
    /// Завершает отслеживание и сохраняет результат
    func finishReading() {
        guard let startTime = startTime,
              let articleId = articleId else { return }
        
        let readingTime = Date().timeIntervalSince(startTime)
        
        // Записываем только если пользователь читал хотя бы 10 секунд
        if readingTime >= 10 {
            ReadingHistoryManager.shared.addReadingEntry(
                articleId: articleId,
                readingTime: readingTime
            )
        }
        
        self.startTime = nil
        self.articleId = nil
    }
    
    /// Получает текущее время чтения
    var currentReadingTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Статистика чтения
struct ReadingStats {
    let totalArticlesRead: Int
    let totalReadingTimeMinutes: Int
    let averageReadingTimeMinutes: Double
    let readingStreak: Int // дни подряд с чтением
    
    init(from history: [ReadingHistoryEntry]) {
        self.totalArticlesRead = Set(history.map { $0.articleId }).count
        
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        self.totalReadingTimeMinutes = Int(totalSeconds / 60)
        
        self.averageReadingTimeMinutes = totalArticlesRead > 0
            ? Double(totalReadingTimeMinutes) / Double(totalArticlesRead)
            : 0
        
        // Расчет streak (упрощенный)
        self.readingStreak = ReadingStats.calculateStreak(from: history)
    }
    
    private static func calculateStreak(from history: [ReadingHistoryEntry]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        for i in 0..<7 { // Проверяем последние 7 дней
            let hasReadingThisDay = history.contains { entry in
                calendar.isDate(entry.readAt, inSameDayAs: currentDate)
            }
            
            if hasReadingThisDay {
                streak += 1
            } else if i > 0 { // Пропускаем сегодня, если сегодня не читали
                break
            }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
}

// MARK: - Sample Data для Preview
extension ReadingHistoryManager {
    static let example: ReadingHistoryManager = {
        let manager = ReadingHistoryManager.shared
        manager.clearHistory()
        manager.addReadingEntry(articleId: "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa", readingTime: 120)
        manager.addReadingEntry(articleId: "22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb", readingTime: 300)
        return manager
    }()
}

#Preview {
    Text("Total read: \(ReadingHistoryManager.example.totalArticlesRead)")
}

