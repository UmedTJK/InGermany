//
//  ArticleSectionDTO.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

import Foundation

/// Ровно та же форма, что ожидает ArticleRenderer / burgeramt_registration.json
struct ArticleSectionDTO: Codable {
    let type: String
    let content: String?
    let items: [ArticleItemDTO]?
    let question: String?
    let answer: String?

    // ✅ image block
    let url: String?
    let caption: String?
    let base64: String?
}

struct ArticleItemDTO: Codable {
    let text: String?
    let isDone: Bool?
    let title: String?
    let articleId: String?
}
