import Foundation

public struct ArticleBlock: Identifiable, Equatable {
    public let id = UUID()
    public var type: BlockType
    public var content: String
    public var items: [ArticleItemDTO]
    public var imageData: ImageData?
    
    public init(type: BlockType, content: String = "", items: [ArticleItemDTO] = [], imageData: ImageData? = nil) {
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
