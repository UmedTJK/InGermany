//
//  Article.swift
//  InGermany
//
//  Updated with dates, reading time functionality and image support
//

import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: String
    let title: [String: String]
    let content: [String: String]
    let categoryId: String
    let tags: [String]
    let pdfFileName: String?
    let createdAt: Date?
    let updatedAt: Date?
    let image: String?   // 🔹 Новое поле для фото статьи
    
    // MARK: - Initializers
    
    init(
        id: String,
        title: [String: String],
        content: [String: String],
        categoryId: String,
        tags: [String] = [],
        pdfFileName: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        image: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryId = categoryId
        self.tags = tags
        self.pdfFileName = pdfFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.image = image
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, categoryId, tags, pdfFileName, createdAt, updatedAt, image
    }
    
    // MARK: - Custom Decoding (для совместимости со старыми JSON)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode([String: String].self, forKey: .title)
        content = try container.decode([String: String].self, forKey: .content)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        pdfFileName = try container.decodeIfPresent(String.self, forKey: .pdfFileName)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        
        // Пытаемся декодировать даты (если их нет в JSON, ставим nil)
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = ISO8601DateFormatter().date(from: createdAtString)
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        } else {
            updatedAt = nil
        }
    }
    
    // MARK: - Custom Encoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(pdfFileName, forKey: .pdfFileName)
        try container.encodeIfPresent(image, forKey: .image)
        
        if let createdAt = createdAt {
            try container.encode(ISO8601DateFormatter().string(from: createdAt), forKey: .createdAt)
        }
        
        if let updatedAt = updatedAt {
            try container.encode(ISO8601DateFormatter().string(from: updatedAt), forKey: .updatedAt)
        }
    }
    
    // MARK: - Hashable
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Localization Methods
    
    func localizedTitle(for language: String) -> String {
        title[language] ?? title["en"] ?? title.values.first ?? "No title"
    }
    
    func localizedContent(for language: String) -> String {
        content[language] ?? content["en"] ?? content.values.first ?? "No content"
    }
    
    // MARK: - Image fallback
    
    var imageName: String {
        image ?? "Logo"
    }
    
    // MARK: - Date Formatting
    
    func formattedCreatedDate(for language: String = "ru") -> String {
        guard let createdAt = createdAt else {
            return getTranslation(key: "Дата неизвестна", language: language)
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        switch language {
        case "en": formatter.locale = Locale(identifier: "en_US")
        case "de": formatter.locale = Locale(identifier: "de_DE")
        case "tj": formatter.locale = Locale(identifier: "ru_RU")
        default: formatter.locale = Locale(identifier: "ru_RU")
        }
        
        return formatter.string(from: createdAt)
    }
    
    func formattedUpdatedDate(for language: String = "ru") -> String {
        guard let updatedAt = updatedAt else {
            return getTranslation(key: "Не обновлялась", language: language)
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        switch language {
        case "en": formatter.locale = Locale(identifier: "en_US")
        case "de": formatter.locale = Locale(identifier: "de_DE")
        case "tj": formatter.locale = Locale(identifier: "ru_RU")
        default: formatter.locale = Locale(identifier: "ru_RU")
        }
        
        return formatter.string(from: updatedAt)
    }
    
    func relativeCreatedDate(for language: String = "ru") -> String {
        guard let createdAt = createdAt else {
            return getTranslation(key: "Дата неизвестна", language: language)
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        switch language {
        case "en": formatter.locale = Locale(identifier: "en_US")
        case "de": formatter.locale = Locale(identifier: "de_DE")
        case "tj": formatter.locale = Locale(identifier: "ru_RU")
        default: formatter.locale = Locale(identifier: "ru_RU")
        }
        
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    // MARK: - Content Analysis
    
    var wordCount: Int {
        let allContent = content.values.joined(separator: " ")
        return ReadingTimeCalculator.estimateReadingTime(for: allContent) * 200
    }
    
    var isNew: Bool {
        guard let createdAt = createdAt else { return false }
        return Date().timeIntervalSince(createdAt) < 7 * 24 * 60 * 60
    }
    
    var isUpdatedRecently: Bool {
        guard let updatedAt = updatedAt else { return false }
        return Date().timeIntervalSince(updatedAt) < 3 * 24 * 60 * 60
    }
    
    // MARK: - Helper Methods
    
    private func getTranslation(key: String, language: String) -> String {
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

// MARK: - Reading Time Extension

extension Article {
    func readingTime(for language: String) -> Int {
        let content = localizedContent(for: language)
        return ReadingTimeCalculator.estimateReadingTime(for: content, language: language)
    }
    
    func formattedReadingTime(for language: String) -> String {
        let minutes = readingTime(for: language)
        return ReadingTimeCalculator.formatReadingTime(minutes, language: language)
    }
}

// MARK: - Sample Data для Preview

extension Article {
    static let sampleArticle: Article = Article(
        id: "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        title: [
            "ru": "Финансы в Германии",
            "en": "Finance in Germany",
            "de": "Finanzen in Deutschland"
        ],
        content: [
            "ru": "Все о финансах и банковской системе в Германии. Как открыть счет, получить кредит и управлять своими финансами.",
            "en": "All about finance and the banking system in Germany. How to open an account, get credit and manage your finances.",
            "de": "Alles über Finanzen und das Bankensystem in Deutschland. Wie Sie ein Konto eröffnen, einen Kredit erhalten und Ihre Finanzen verwalten."
        ],
        categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa",
        tags: ["финансы", "банк", "кредит"],
        pdfFileName: "Test_Document",
        createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
        updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
        image: "bank_account.jpg"
    )
    
    static let sampleArticles: [Article] = [
        sampleArticle,
        Article(
            id: "22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
            title: [
                "ru": "Поиск работы в Германии",
                "en": "Job search in Germany",
                "de": "Jobsuche in Deutschland"
            ],
            content: [
                "ru": "Подробное руководство по поиску работы в Германии. Составление резюме, собеседования и трудовые права.",
                "en": "Complete guide to finding work in Germany. CV writing, interviews and labor rights.",
                "de": "Vollständiger Leitfaden zur Arbeitssuche in Deutschland. Lebenslauf schreiben, Interviews und Arbeitsrechte."
            ],
            categoryId: "22222222-2222-2222-2222-bbbbbbbbbbbb",
            tags: ["работа", "резюме", "собеседование"],
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            image: "job_search.jpg"
        )
    ]
}
