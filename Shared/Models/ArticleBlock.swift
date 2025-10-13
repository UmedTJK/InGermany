//
//  ArticleBlock.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//
import Foundation

public enum BlockType: String, Codable, CaseIterable {
    case paragraph, info, warning, tip, quote, checklist, faq, list
}

/// Внутренняя модель редактора
public struct ArticleBlock: Identifiable, Codable, Equatable {
    public let id: UUID
    public var type: BlockType
    public var content: String
    /// Для faq: ["question": "...", "answer": "..."]
    public var extra: [String: String]?

    public init(
        id: UUID = UUID(),
        type: BlockType,
        content: String = "",
        extra: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.extra = extra
    }
}

