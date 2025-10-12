//
//  ReadingHistoryEntry.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import Foundation

/// Одна запись в истории чтения
struct ReadingHistoryEntry: Codable, Identifiable {
    let id: UUID
    let articleId: String
    let readAt: Date
    let readingTimeSeconds: TimeInterval

    init(articleId: String, readAt: Date = Date(), readingTimeSeconds: TimeInterval = 0) {
        self.id = UUID()
        self.articleId = articleId
        self.readAt = readAt
        self.readingTimeSeconds = readingTimeSeconds
    }
}

