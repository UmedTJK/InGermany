//
//  ArticleSectionDTO.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//
import Foundation

/// DTO для совместимости с ArticleRenderer / burgeramt_registration.json
public struct ArticleSectionDTO: Codable {
    public let type: String
    public let content: String?
    public let items: [ArticleItemDTO]?
    public let question: String?
    public let answer: String?

    // ✅ image block
    public let url: String?
    public let caption: String?
    public let base64: String?

    public init(
        type: String,
        content: String? = nil,
        items: [ArticleItemDTO]? = nil,
        question: String? = nil,
        answer: String? = nil,
        url: String? = nil,
        caption: String? = nil,
        base64: String? = nil
    ) {
        self.type = type
        self.content = content
        self.items = items
        self.question = question
        self.answer = answer
        self.url = url
        self.caption = caption
        self.base64 = base64
    }
}

public struct ArticleItemDTO: Codable {
    public let text: String?
    public let isDone: Bool?
    public let title: String?
    public let articleId: String?
    
    public init(text: String? = nil, isDone: Bool? = nil, title: String? = nil, articleId: String? = nil) {
        self.text = text
        self.isDone = isDone
        self.title = title
        self.articleId = articleId
    }
}
