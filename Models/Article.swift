//
//  Article.swift
//  InGermany
//
//  Updated with centralized date formatting via DateFormatterUtils
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
    
    // MARK: - Initializers
    
    init(
        id: String,
        title: [String: String],
        content: [String: String],
        categoryId: String,
        tags: [String] = [],
        pdfFileName: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryId = categoryId
        self.tags = tags
        self.pdfFileName = pdfFileName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, categoryId, tags, pdfFileName, createdAt, updatedAt
    }
    
    // MARK: - Custom Decoding (совместимость со старыми JSON)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode([String: String].self, forKey: .title)
        content = try container.decode([String: String].self, forKey: .content)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        pdfFileName = try container.decodeIfPresent(String.self, forKey: .pdfFileName)
        
        // Пытаемся декодировать даты
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
}

// MARK: - Date Formatting (delegated to Utils)

extension Article {
    func formattedCreatedDate(for language: String = "ru") -> String {
        DateFormatterUtils.formattedDate(createdAt, language: language)
    }
    
    func formattedUpdatedDate(for language: String = "ru") -> String {
        DateFormatterUtils.formattedDate(updatedAt, language: language)
    }
    
    func relativeCreatedDate(for language: String = "ru") -> String {
        DateFormatterUtils.relativeDate(createdAt, language: language)
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

// MARK: - Content Analysis

extension Article {
    var isNew: Bool {
        guard let createdAt = createdAt else { return false }
        return Date().timeIntervalSince(createdAt) < 7 * 24 * 60 * 60
    }
    
    var isUpdatedRecently: Bool {
        guard let updatedAt = updatedAt else { return false }
        return Date().timeIntervalSince(updatedAt) < 3 * 24 * 60 * 60
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
            "ru": "Все о финансах и банковской системе в Германии...",
            "en": "All about finance and the banking system in Germany...",
            "de": "Alles über Finanzen und das Bankensystem in Deutschland..."
        ],
        categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa",
        tags: ["финансы", "банк", "кредит"],
        pdfFileName: "Test_Document",
        createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
        updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())
    )
    
    static let sampleArticles: [Article] = [
        sampleArticle
    ]
}
