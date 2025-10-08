//
//  TextAnalysisService.swift
//  InGermany
//
//  Created by SUM TJK on 08.10.25.

import Foundation

protocol TextAnalysisServiceProtocol {
    func wordCount(for text: String) -> Int
    func readingTime(for text: String, language: String) -> Int
}

class TextAnalysisService: TextAnalysisServiceProtocol {
    static let shared = TextAnalysisService()
    
    private init() {}
    
    func wordCount(for text: String) -> Int {
        let components = text.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }
    
    func readingTime(for text: String, language: String) -> Int {
        let words = wordCount(for: text)
        let wordsPerMinute: Int
        
        switch language {
        case "de": wordsPerMinute = 180  // Немецкий сложнее для чтения
        case "en": wordsPerMinute = 200
        case "ru": wordsPerMinute = 190
        case "tj": wordsPerMinute = 170  // Таджикский может быть сложнее
        default: wordsPerMinute = 200
        }
        
        let minutes = Double(words) / Double(wordsPerMinute)
        return Int(ceil(minutes))
    }
}
