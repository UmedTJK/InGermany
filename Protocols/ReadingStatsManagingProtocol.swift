//
//  ReadingStatsManagingProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 09.10.25.
//

import SwiftUI

@MainActor
protocol ReadingStatsManagingProtocol {
    // Progress
    func updateProgress(for articleID: String, value: CGFloat)
    func progressForArticle(_ articleID: String) -> CGFloat
    func resetProgress(for articleID: String)

    // Sessions
    func startSession(articleId: String)
    func endSession(articleId: String)
    func currentReadingTime(for articleId: String) -> TimeInterval

    // History
    func addReadingEntry(articleId: String, readingTime: TimeInterval)
    func recentlyReadArticles(from allArticles: [Article], limit: Int) -> [Article]
    func isRead(_ articleId: String) -> Bool
    func lastReadDate(for articleId: String) -> Date?
    func clearHistory()   // ✅ ДОБАВЛЕНО

    // Stats
    var totalReadingTimeMinutes: Int { get }
    var totalArticlesRead: Int { get }
    func getStats() -> ReadingStats

    // Helpers
    func estimateReadingTime(for text: String, language: String) -> Int
    func formatReadingTime(_ minutes: Int, language: String) -> String
    func progressStatus(for progress: CGFloat, language: String) -> String
}
