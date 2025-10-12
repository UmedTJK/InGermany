//
//  ReadingStats.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import Foundation

/// Сводная статистика чтения
struct ReadingStats: Codable {
    let totalReadCount: Int
    let totalReadingTimeSeconds: TimeInterval
    let lastReadDate: Date?

    init(totalReadCount: Int, totalReadingTimeSeconds: TimeInterval, lastReadDate: Date?) {
        self.totalReadCount = totalReadCount
        self.totalReadingTimeSeconds = totalReadingTimeSeconds
        self.lastReadDate = lastReadDate
    }

    init(from history: [ReadingHistoryEntry]) {
        self.totalReadCount = history.count
        self.totalReadingTimeSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        self.lastReadDate = history.first?.readAt
    }

    static let empty = ReadingStats(totalReadCount: 0,
                                    totalReadingTimeSeconds: 0,
                                    lastReadDate: nil)
}

