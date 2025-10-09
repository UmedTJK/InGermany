//
//  ReadingTimeCalculator.swift
//  InGermany
//
//  Created by SUM TJK on 09.10.25.
//
import Foundation

enum ReadingTimeCalculator {
    static func estimateReadingTime(for text: String, language: String, wordsPerMinute: Int = 200) -> Int {
        let words = text.split { $0.isWhitespace || $0.isNewline }.count
        return max(1, words / wordsPerMinute)
    }

    static func formatReadingTime(_ minutes: Int, language: String) -> String {
        switch language {
        case "ru":
            return "\(minutes) мин"
        case "en":
            return "\(minutes) min"
        default:
            return "\(minutes)"
        }
    }
}

