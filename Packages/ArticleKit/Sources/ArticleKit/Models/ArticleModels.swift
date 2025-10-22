import Foundation

// MARK: - Основные модели данных
public struct ArticleSectionDTO: Codable, Identifiable {
    public var id: UUID
    public var type: String
    public var content: String?
    public var items: [ArticleItemDTO]?
    public var imageData: ImageData?
    
    public init(type: String, content: String? = nil, items: [ArticleItemDTO]? = nil, imageData: ImageData? = nil) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.items = items
        self.imageData = imageData
    }
}

public struct ArticleItemDTO: Codable, Identifiable, Equatable {
    public var id: UUID
    public var text: String
    public var isCompleted: Bool?
    public var title: String?
    public var articleId: String?
    
    public init(text: String, isCompleted: Bool? = nil, title: String? = nil, articleId: String? = nil) {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.title = title
        self.articleId = articleId
    }
    
    public static func == (lhs: ArticleItemDTO, rhs: ArticleItemDTO) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.title == rhs.title &&
        lhs.articleId == rhs.articleId
    }
}

public struct ImageData: Codable, Equatable {
    public var imagePath: String?
    public var caption: String
    public var altText: String
    
    public init(imagePath: String? = nil, caption: String = "", altText: String = "") {
        self.imagePath = imagePath
        self.caption = caption
        self.altText = altText
    }
}

public struct ArticleDocument: Codable, Identifiable, Hashable {
    public var id: UUID
    public var title: String
    public var sections: [ArticleSectionDTO]
    public var url: URL?
    
    public init(title: String, sections: [ArticleSectionDTO], url: URL? = nil) {
        self.id = UUID()
        self.title = title
        self.sections = sections
        self.url = url
    }
    
    public static func == (lhs: ArticleDocument, rhs: ArticleDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
