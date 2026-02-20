//
//  ArticleFormatter.swift
//  InGermany
//
//  Created by SUM TJK on 08.10.25.
//

import Foundation

final class ArticleFormatter {
    private let dateFormattingService: DateFormattingServiceProtocol
    private let textAnalysisService: TextAnalysisServiceProtocol

    init(
        dateFormattingService: DateFormattingServiceProtocol,
        textAnalysisService: TextAnalysisServiceProtocol
    ) {
        self.dateFormattingService = dateFormattingService
        self.textAnalysisService = textAnalysisService
    }

    func formattedCreatedDate(_ article: Article, for language: String) -> String {
        guard let createdAt = article.createdAt else {
            return localizedFallback("Дата неизвестна", for: language)
        }
        return dateFormattingService.formattedDate(createdAt, for: language)
    }

    func formattedUpdatedDate(_ article: Article, for language: String) -> String {
        guard let updatedAt = article.updatedAt else {
            return localizedFallback("Не обновлялась", for: language)
        }
        return dateFormattingService.formattedDate(updatedAt, for: language)
    }

    func relativeCreatedDate(_ article: Article, for language: String) -> String {
        guard let createdAt = article.createdAt else {
            return localizedFallback("Дата неизвестна", for: language)
        }
        return dateFormattingService.relativeDate(createdAt, for: language)
    }

    func wordCount(_ article: Article, for language: String) -> Int {
        let content = article.localizedContent(for: language)
        return textAnalysisService.wordCount(for: content)
    }

    func readingTime(_ article: Article, for language: String) -> Int {
        let content = article.localizedContent(for: language)
        return textAnalysisService.readingTime(for: content, language: language)
    }

    private func localizedFallback(_ key: String, for language: String) -> String {
        let translations: [String: [String: String]] = [
            "Дата неизвестна": [
                "ru": "Дата неизвестна",
                "en": "Date unknown",
                "de": "Datum unbekannt",
                "tj": "Сана номаълум"
            ],
            "Не обновлялась": [
                "ru": "Не обновлялась",
                "en": "Not updated",
                "de": "Nicht aktualisiert",
                "tj": "Навсозӣ нашуд"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

// MARK: - ArticleFormatterProtocol Implementation
extension ArticleFormatter: ArticleFormatterProtocol {
    func formatReadingTime(_ minutes: Int, language: String) -> String {
        switch language {
        case "ru":
            return "\(minutes) мин."
        case "en":
            return "\(minutes) min"
        case "de":
            return "\(minutes) Min."
        case "tj":
            return "\(minutes) дақ."
        default:
            return "\(minutes) min"
        }
    }
}
