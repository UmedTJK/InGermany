import Foundation

public struct ArticleSectionDTO: Codable, Identifiable {
    public let id = UUID()
    public let type: String
    public let content: String?
    public let items: [ArticleItemDTO]?
    public let imageData: ImageData? // ✅ ДОБАВЛЯЕМ ДАННЫЕ ИЗОБРАЖЕНИЯ
    
    public init(type: String, content: String? = nil, items: [ArticleItemDTO]? = nil, imageData: ImageData? = nil) {
        self.type = type
        self.content = content
        self.items = items
        self.imageData = imageData
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

// ✅ НОВАЯ МОДЕЛЬ: Данные изображения
public struct ImageData: Codable, Equatable {
    public var imagePath: String? // Путь к файлу
    public var caption: String    // Подпись
    public var altText: String    // Альтернативный текст
    
    public init(imagePath: String? = nil, caption: String = "", altText: String = "") {
        self.imagePath = imagePath
        self.caption = caption
        self.altText = altText
    }
    
    public static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.imagePath == rhs.imagePath &&
        lhs.caption == rhs.caption &&
        lhs.altText == rhs.altText
    }
}
