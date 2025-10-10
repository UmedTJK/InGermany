//
//  ArticleFormatterProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
// Protocols/ArticleFormatterProtocol.swift
import Foundation

/// Протокол для форматирования статей
protocol ArticleFormatterProtocol {
    func formattedCreatedDate(_ article: Article, for language: String) -> String
    func formattedUpdatedDate(_ article: Article, for language: String) -> String
    func relativeCreatedDate(_ article: Article, for language: String) -> String
    func wordCount(_ article: Article, for language: String) -> Int
    func readingTime(_ article: Article, for language: String) -> Int
    func formatReadingTime(_ minutes: Int, language: String) -> String
}
