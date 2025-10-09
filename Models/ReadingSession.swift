//
//  ReadingSession.swift
//  InGermany
//
//  Created by SUM TJK on 09.10.25.
//
import Foundation

struct ReadingSession: Codable, Identifiable {
    var id = UUID()
    let articleId: String
    let startTime: Date
    var endTime: Date?

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }
}

