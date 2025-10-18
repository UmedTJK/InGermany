import Foundation

public struct ArticleDocument: Codable, Identifiable, Hashable {
    public let id = UUID()
    public var title: String // ✅ ИЗМЕНИЛИ НА var ДЛЯ РЕДАКТИРОВАНИЯ
    public var sections: [ArticleSectionDTO]
    public let url: URL?
    
    public init(title: String, sections: [ArticleSectionDTO], url: URL? = nil) {
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
