import Foundation

public enum ArticleStatus: String, Codable, Sendable {
    case draft
    case published
    case archived
}

public struct Article: Codable, Hashable, Sendable {
    public var id: ArticleID
    public var slug: String
    public var title: LocalizedText
    public var summary: LocalizedText?
    public var categoryIDs: [CategoryID]
    public var tagIDs: [TagID]
    public var blocks: [ContentBlock]
    public var status: ArticleStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var publishedAt: Date?

    public init(
        id: ArticleID,
        slug: String,
        title: LocalizedText,
        summary: LocalizedText? = nil,
        categoryIDs: [CategoryID] = [],
        tagIDs: [TagID] = [],
        blocks: [ContentBlock] = [],
        status: ArticleStatus = .draft,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = nil
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.summary = summary
        self.categoryIDs = categoryIDs
        self.tagIDs = tagIDs
        self.blocks = blocks
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
    }
}
