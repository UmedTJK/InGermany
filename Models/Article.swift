//
//  Article.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  Article.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  Article.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

struct Article: Identifiable, Codable {
    let id: String
    let title: [String: String]
    let content: [String: String]
    let categoryId: String
    let tags: [String]

    func localizedTitle(for language: String) -> String {
        title[language] ?? title["de"] ?? title["en"] ?? title["ru"] ?? "Без названия"
    }

    func localizedContent(for language: String) -> String {
        content[language] ?? content["de"] ?? content["en"] ?? content["ru"] ?? ""
    }
}

// MARK: - Sample for previews
extension Article {
    static let sample = Article(
        id: "11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        title: [
            "ru": "Пример статьи",
            "en": "Sample Article",
            "de": "Beispielartikel",
            "tj": "Мақолаи намунавӣ"
        ],
        content: [
            "ru": "Это пример текста статьи для превью.",
            "en": "This is a sample text for preview.",
            "de": "Dies ist ein Beispieltext für die Vorschau.",
            "tj": "Ин матни намунавии мақола барои пешнамоиш аст."
        ],
        categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa",
        tags: ["пример", "sample", "beispiel", "намуна"]
    )
}
