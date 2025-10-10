//
//  Article.swift (ИСПРАВЛЕННАЯ ВЕРСИЯ)
//  InGermany
//

import Foundation

/// Чистая модель данных статьи без бизнес-логики
struct Article: Identifiable, Codable, Hashable {
    /// Unique identifier for the article.
    let id: String
    /// Localized titles keyed by language code.
    let title: [String: String]
    /// Localized content keyed by language code.
    let content: [String: String]
    /// Identifier of the category this article belongs to.
    let categoryId: String
    /// Tags associated with the article for categorization and search.
    let tags: [String]
    /// Optional filename of an associated PDF document.
    let pdfFileName: String?
    /// Optional creation date of the article.
    let createdAt: Date?
    /// Optional last updated date of the article.
    let updatedAt: Date?
    /// Optional image filename associated with the article.
    let image: String?
    
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
    
    // MARK: - Custom Decoding (УПРОЩЕННЫЙ И ИСПРАВЛЕННЫЙ)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode([String: String].self, forKey: .title)
        content = try container.decode([String: String].self, forKey: .content)
        categoryId = try container.decode(String.self, forKey: .categoryId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        pdfFileName = try container.decodeIfPresent(String.self, forKey: .pdfFileName)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        
        // 🔧 ИСПРАВЛЕНО: Упрощенное декодирование дат
        let dateFormatter = ISO8601DateFormatter()
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString)
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
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let createdAt = createdAt {
            try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        }
        
        if let updatedAt = updatedAt {
            try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
        }
    }
    
    // MARK: - Hashable
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Localization Methods (оставляем только чистые геттеры)
    
    /// Returns the localized title for the given language
    func localizedTitle(for language: String) -> String {
        title[language] ?? title["en"] ?? title.values.first ?? "No title"
    }
    
    /// Returns the localized content for the given language
    func localizedContent(for language: String) -> String {
        content[language] ?? content["en"] ?? content.values.first ?? "No content"
    }
    
    // MARK: - Image fallback (оставляем как чистую логику преобразования)
    
    /// Provides the normalized image filename with fallback logic
    var imageName: String {
        guard var img = image else { return "Logo" }
        
        // AVIF → JPG
        if img.hasSuffix(".avif") {
            img = img.replacingOccurrences(of: ".avif", with: ".jpg")
        }
        
        // Если без расширения — добавляем .jpg
        if !img.contains(".") {
            img += ".jpg"
        }
        
        return img
    }
    
    // MARK: - Computed Properties (только чистые вычисления без внешних зависимостей)
    
    /// Indicates whether the article is considered new (created within the last 7 days).
    var isNew: Bool {
        guard let createdAt = createdAt else { return false }
        return Date().timeIntervalSince(createdAt) < 7 * 24 * 60 * 60
    }
    
    /// Indicates whether the article was updated recently (within the last 3 days).
    var isUpdatedRecently: Bool {
        guard let updatedAt = updatedAt else { return false }
        return Date().timeIntervalSince(updatedAt) < 3 * 24 * 60 * 60
    }
}

extension Article {
    /// Подсчитывает количество слов в контенте для данного языка.
    func wordCount(for language: String) -> Int {
        let text = localizedContent(for: language)
        // Разбиваем по непробельным разделителям (пунктуация плюс пробелы)
        let tokens = text
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty }
        return tokens.count
    }
}

// MARK: - Sample Data для Preview (без изменений)

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
