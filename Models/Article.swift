//
//  Article.swift
//  InGermany
//

import Foundation

// 1. Добавляем соответствие Hashable
struct Article: Identifiable, Codable, Hashable {
    let id: String
    let title: [String: String]
    let content: [String: String]
    let categoryId: String
    let tags: [String]
    let pdfFileName: String?
    
    // 2. Реализуем Hashable на основе id (уникальный идентификатор)
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Методы локализации
    func localizedTitle(for language: String) -> String {
        title[language] ?? title["en"] ?? title.values.first ?? "No title"
    }
    
    func localizedContent(for language: String) -> String {
        content[language] ?? content["en"] ?? content.values.first ?? "No content"
    }
}

// 🔹 Пример статьи для превью
extension Article {
    static let sampleArticle: Article = Article(
        id: "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        title: [
            "ru": "Финансы в Германии",
            "en": "Finance in Germany"
        ],
        content: [
            "ru": "Все о финансах и банковской системе",
            "en": "All about finance and the banking system"
        ],
        categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa",
        tags: ["финансы", "банк"],
        pdfFileName: "Test_Document"
    )
}
