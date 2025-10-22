import Foundation

public enum BlockType: String, CaseIterable, Codable {
    case paragraph, info, warning, tip, quote
    case checklist, faq, list, links, image
}

public struct ArticleBlock: Identifiable, Equatable, Codable {
    public let id: UUID
    public var type: BlockType
    public var content: String
    public var items: [ArticleItemDTO]
    public var imageData: ImageData?
    
    public init(type: BlockType, content: String = "", items: [ArticleItemDTO] = [], imageData: ImageData? = nil) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.items = items
        self.imageData = imageData
    }
    
    public static func == (lhs: ArticleBlock, rhs: ArticleBlock) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.content == rhs.content &&
        lhs.items == rhs.items &&
        lhs.imageData == rhs.imageData
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case id, type, content, items, imageData
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(BlockType.self, forKey: .type)
        content = try container.decode(String.self, forKey: .content)
        items = try container.decode([ArticleItemDTO].self, forKey: .items)
        imageData = try container.decodeIfPresent(ImageData.self, forKey: .imageData)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(content, forKey: .content)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }
    
    // MARK: - Transformations
    public static func fromSection(_ section: ArticleSectionDTO) -> ArticleBlock {
        return ArticleBlock(
            type: BlockType(rawValue: section.type) ?? .paragraph,
            content: section.content ?? "",
            items: section.items ?? [],
            imageData: section.imageData
        )
    }
    
    public func toSectionDTO() -> ArticleSectionDTO {
        return ArticleSectionDTO(
            type: type.rawValue,
            content: content.isEmpty ? nil : content,
            items: items.isEmpty ? nil : items,
            imageData: imageData
        )
    }
}
