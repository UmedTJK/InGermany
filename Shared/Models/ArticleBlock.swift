//
//  ArticleBlock.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

import Foundation

public enum BlockType: String, Codable, CaseIterable {
    case paragraph, info, warning, tip, quote, checklist, faq, list, links
    case image // ✅ новый тип
}

// MARK: - Payloads used by the editor

public struct ChecklistEntry: Codable, Hashable {
    public var text: String
    public var isDone: Bool
    public init(text: String = "", isDone: Bool = false) {
        self.text = text
        self.isDone = isDone
    }
}

public struct LinkEntry: Codable, Hashable {
    public var title: String
    public var articleId: String
    public init(title: String = "", articleId: String = "") {
        self.title = title
        self.articleId = articleId
    }
}

public enum BlockPayload: Codable, Equatable {
    case content(String)                          // paragraph / info / warning / tip / quote
    case list([String])                           // list
    case checklist([ChecklistEntry])              // checklist
    case faq(question: String, answer: String)    // faq
    case links([LinkEntry])                       // links
    case image(url: String?, caption: String?, base64: String?) // ✅ image

    // MARK: - Codable support
    private enum CodingKeys: String, CodingKey {
        case kind, content, list, checklist, question, answer, links
        case url, caption, base64
    }

    private enum Kind: String, Codable { case content, list, checklist, faq, links, image }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .content(let text):
            try c.encode(Kind.content, forKey: .kind)
            try c.encode(text, forKey: .content)
        case .list(let items):
            try c.encode(Kind.list, forKey: .kind)
            try c.encode(items, forKey: .list)
        case .checklist(let items):
            try c.encode(Kind.checklist, forKey: .kind)
            try c.encode(items, forKey: .checklist)
        case .faq(let q, let a):
            try c.encode(Kind.faq, forKey: .kind)
            try c.encode(q, forKey: .question)
            try c.encode(a, forKey: .answer)
        case .links(let links):
            try c.encode(Kind.links, forKey: .kind)
            try c.encode(links, forKey: .links)
        case .image(let url, let caption, let base64):
            try c.encode(Kind.image, forKey: .kind)
            try c.encodeIfPresent(url, forKey: .url)
            try c.encodeIfPresent(caption, forKey: .caption)
            try c.encodeIfPresent(base64, forKey: .base64)
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .content:
            self = .content(try c.decode(String.self, forKey: .content))
        case .list:
            self = .list(try c.decode([String].self, forKey: .list))
        case .checklist:
            self = .checklist(try c.decode([ChecklistEntry].self, forKey: .checklist))
        case .faq:
            let q = try c.decode(String.self, forKey: .question)
            let a = try c.decode(String.self, forKey: .answer)
            self = .faq(question: q, answer: a)
        case .links:
            self = .links(try c.decode([LinkEntry].self, forKey: .links))
        case .image:
            let url = try c.decodeIfPresent(String.self, forKey: .url)
            let caption = try c.decodeIfPresent(String.self, forKey: .caption)
            let base64 = try c.decodeIfPresent(String.self, forKey: .base64)
            self = .image(url: url, caption: caption, base64: base64)
        }
    }
}

public struct ArticleBlock: Identifiable, Codable, Equatable {
    public let id: UUID
    public var type: BlockType
    public var payload: BlockPayload

    public init(id: UUID = UUID(), type: BlockType, payload: BlockPayload) {
        self.id = id
        self.type = type
        self.payload = payload
    }
}

// MARK: - Mapping from DTO

extension ArticleBlock {
    static func fromSection(_ section: ArticleSectionDTO) -> ArticleBlock {
        switch section.type {
        case "paragraph", "info", "warning", "tip", "quote":
            return ArticleBlock(
                type: BlockType(rawValue: section.type) ?? .paragraph,
                payload: .content(section.content ?? "")
            )
        case "list":
            let items = section.items?.compactMap { $0.text } ?? []
            return ArticleBlock(type: .list, payload: .list(items))
        case "checklist":
            let entries = section.items?.map {
                ChecklistEntry(text: $0.text ?? "", isDone: $0.isDone ?? false)
            } ?? []
            return ArticleBlock(type: .checklist, payload: .checklist(entries))
        case "faq":
            return ArticleBlock(
                type: .faq,
                payload: .faq(question: section.question ?? "", answer: section.answer ?? "")
            )
        case "links":
            let links = section.items?.map {
                LinkEntry(title: $0.title ?? "", articleId: $0.articleId ?? "")
            } ?? []
            return ArticleBlock(type: .links, payload: .links(links))
        case "image":
            return ArticleBlock(
                type: .image,
                payload: .image(
                    url: section.url,
                    caption: section.caption,
                    base64: section.base64
                )
            )
        default:
            return ArticleBlock(type: .paragraph, payload: .content(section.content ?? ""))
        }
    }
}
