import Foundation

public struct ArticleBlock: Identifiable, Equatable {
    public let id = UUID()
    public var type: BlockType
    public var content: String
    public var items: [ArticleItemDTO]
    
    public init(type: BlockType, content: String = "", items: [ArticleItemDTO] = []) {
        self.type = type
        self.content = content
        self.items = items
    }
    
    public static func == (lhs: ArticleBlock, rhs: ArticleBlock) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Transformations
    
    public static func fromSection(_ section: ArticleSectionDTO) -> ArticleBlock {
        return ArticleBlock(
            type: BlockType(rawValue: section.type) ?? .paragraph,
            content: section.content ?? "",
            items: section.items ?? []
        )
    }
    
    public func toSectionDTO() -> ArticleSectionDTO {
        return ArticleSectionDTO(
            type: type.rawValue,
            content: content.isEmpty ? nil : content,
            items: items.isEmpty ? nil : items
        )
    }
}
