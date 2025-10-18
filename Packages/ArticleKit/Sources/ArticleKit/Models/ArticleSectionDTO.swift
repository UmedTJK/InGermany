import Foundation

public struct ArticleSectionDTO: Codable, Identifiable {
    public let id = UUID()
    public let type: String
    public let content: String?
    public let items: [ArticleItemDTO]?
    
    public init(type: String, content: String? = nil, items: [ArticleItemDTO]? = nil) {
        self.type = type
        self.content = content
        self.items = items
    }
}

public struct ArticleItemDTO: Codable, Identifiable, Equatable {
    public let id = UUID()
    public var text: String
    public var isCompleted: Bool?
    
    public init(text: String, isCompleted: Bool? = nil) {
        self.text = text
        self.isCompleted = isCompleted
    }
    
    public static func == (lhs: ArticleItemDTO, rhs: ArticleItemDTO) -> Bool {
        lhs.id == rhs.id
    }
}
