//
//  ReadingHistoryManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

//
//  ReadingHistoryManager.swift
//  InGermany
//

import Foundation

@MainActor
final class ReadingHistoryManager: ObservableObject {
    static let shared = ReadingHistoryManager()
    
    @Published private(set) var readingHistory: [String: Date] = [:]
    private let key = "readingHistory"
    
    private init() {
        load()
    }
    
    func markAsRead(_ articleId: String) {
        readingHistory[articleId] = Date()
        save()
    }
    
    func isRead(_ articleId: String) -> Bool {
        readingHistory[articleId] != nil
    }
    
    func lastReadDate(for articleId: String) -> Date? {
        readingHistory[articleId]
    }
    
    func clearForTesting() {
        readingHistory.removeAll()
        save()
    }
    
    private func save() {
        // Реализация сохранения
    }
    
    private func load() {
        // Реализация загрузки
    }
}
