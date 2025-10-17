// MARK: - Article Renderer (works with DTO)

import SwiftUI

/// Article Renderer (работает с DTO)
public struct ArticleRenderer: View {
    public let sections: [ArticleSectionDTO]   // ✅ единый DTO

    public init(sections: [ArticleSectionDTO]) {
        self.sections = sections
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    renderSection(section)
                }
            }
            .padding()
        }
    }

    // MARK: - Section rendering
    @ViewBuilder
    public func renderSection(_ section: ArticleSectionDTO) -> some View {
        switch section.type {
        case "paragraph":
            if let content = section.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

        case "info":
            if let content = section.content {
                ArticleBlockView(text: content, style: .info)
            }

        case "warning":
            if let content = section.content {
                ArticleBlockView(text: content, style: .warning)
            }

        case "tip":
            if let content = section.content {
                ArticleBlockView(text: content, style: .tip)
            }

        case "quote":
            if let content = section.content {
                ArticleBlockView(text: content, style: .quote)
            }

        case "checklist":
            if let items = section.items {
                ChecklistCardView(items: items.map {
                    ChecklistItem(text: $0.text ?? "", isDone: $0.isDone ?? false)
                })
            }

        case "faq":
            if let q = section.question, let a = section.answer {
                FAQBlockView(question: q, answer: a)
            }

        case "links":
            if let items = section.items {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        if let title = item.title {
                            Text("🔗 \(title)")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

        case "image":
            imageBlock(urlString: section.url, base64: section.base64, caption: section.caption)

        case "list":
            if let items = section.items {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Text("• \(item.text ?? "")")
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 4)
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Image block view
    @ViewBuilder
    public func imageBlock(urlString: String?, base64: String?, caption: String?) -> some View {
        VStack(spacing: 8) {
            if let s = urlString, let url = URL(string: s) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFit()
                    case .failure: Image(systemName: "xmark.octagon")
                    @unknown default: EmptyView()
                    }
                }
            } else if let base64, let data = Data(base64Encoded: base64) {
                #if canImport(UIKit)
                if let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFit()
                } else {
                    Image(systemName: "xmark.octagon")
                }
                #elseif canImport(AppKit)
                if let ns = NSImage(data: data) {
                    Image(nsImage: ns).resizable().scaledToFit()
                } else {
                    Image(systemName: "xmark.octagon")
                }
                #else
                Image(systemName: "xmark.octagon")
                #endif
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    Text("Image unavailable")
                }
                .frame(height: 160)
            }

            if let c = caption, !c.isEmpty {
                Text(c)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Loader (DTO-based)

public func loadArticleDTO(named filename: String) -> [ArticleSectionDTO] {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([ArticleSectionDTO].self, from: data) else {
        print("⚠️ Не удалось загрузить \(filename).json")
        return []
    }
    return decoded
}
