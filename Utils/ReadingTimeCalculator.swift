//
//  ReadingTimeCalculator.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import Foundation

struct ReadingTimeCalculator {
    
    /// Средняя скорость чтения (слов в минуту) для разных языков
    private static let wordsPerMinute: [String: Int] = [
        "ru": 200,  // Русский
        "en": 250,  // Английский
        "de": 220,  // Немецкий
        "tj": 180   // Таджикский (консервативная оценка)
    ]
    
    /// Рассчитывает время чтения статьи в минутах
    /// - Parameters:
    ///   - text: Текст статьи
    ///   - language: Код языка (ru, en, de, tj)
    /// - Returns: Время чтения в минутах (минимум 1 минута)
    static func estimateReadingTime(for text: String, language: String = "ru") -> Int {
        let wordCount = countWords(in: text)
        let wpm = wordsPerMinute[language] ?? wordsPerMinute["ru"]!
        
        let minutes = max(1, Int(ceil(Double(wordCount) / Double(wpm))))
        return minutes
    }
    
    /// Подсчитывает количество слов в тексте
    private static func countWords(in text: String) -> Int {
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return words.count
    }
    
    /// Возвращает форматированную строку времени чтения
    /// - Parameters:
    ///   - minutes: Количество минут
    ///   - language: Код языка для локализации
    /// - Returns: Строка вида "3 мин чтения" или "1 min read"
    static func formatReadingTime(_ minutes: Int, language: String = "ru") -> String {
        switch language {
        case "en":
            return minutes == 1 ? "1 min read" : "\(minutes) min read"
        case "de":
            return minutes == 1 ? "1 Min. Lesezeit" : "\(minutes) Min. Lesezeit"
        case "tj":
            return minutes == 1 ? "1 дақ хондан" : "\(minutes) дақ хондан"
        default: // "ru"
            return minutes == 1 ? "1 мин чтения" : "\(minutes) мин чтения"
        }
    }
}

// MARK: - Note: Article extensions moved to Article.swift to avoid conflicts
