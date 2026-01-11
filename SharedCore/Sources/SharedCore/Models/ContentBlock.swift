import Foundation

public enum ListStyle: String, Codable, Sendable {
    case bullet
    case numbered
}

public enum MediaSource: Codable, Hashable, Sendable {
    case remote(url: URL)
    case asset(name: String)
}

public struct ImageRef: Codable, Hashable, Sendable {
    public var id: String
    public var source: MediaSource
    public var alt: LocalizedText?
    public var caption: LocalizedText?

    public init(
        id: String,
        source: MediaSource,
        alt: LocalizedText? = nil,
        caption: LocalizedText? = nil
    ) {
        self.id = id
        self.source = source
        self.alt = alt
        self.caption = caption
    }
}

public enum ContentBlock: Codable, Hashable, Sendable {
    case heading(level: Int, text: LocalizedText)
    case paragraph(text: LocalizedText)
    case image(ImageRef)
    case quote(text: LocalizedText, caption: LocalizedText?)
    case list(style: ListStyle, items: [LocalizedText])
    case divider
    case code(language: String?, code: String)
}

