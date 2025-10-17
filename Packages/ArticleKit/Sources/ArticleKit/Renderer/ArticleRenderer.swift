import SwiftUI

/// Article Renderer (работает с DTO)
public struct ArticleRenderer: View {
    public let sections: [ArticleSectionDTO]

    public init(sections: [ArticleSectionDTO]) {
        self.sections = sections
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                    renderSection(section)
                }
            }
            .padding()
        }
    }

    // MARK: - Section rendering
    @ViewBuilder
    private func renderSection(_ section: ArticleSectionDTO) -> some View {
        switch section.type {
        case "paragraph":
            if let content = section.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

        case "info", "warning", "tip", "quote":
            if let content = section.content {
                SimpleBlockView(text: content, style: section.type)
            }

        case "checklist":
            if let items = section.items {
                SimpleChecklistView(items: items)
            }

        case "faq":
            if let q = section.question, let a = section.answer {
                SimpleFAQView(question: q, answer: a)
            }

        case "links":
            if let items = section.items {
                SimpleLinksView(items: items)
            }

        case "image":
            SimpleImageView(urlString: section.url, base64: section.base64, caption: section.caption)

        case "list":
            if let items = section.items {
                SimpleListView(items: items)
            }

        default:
            EmptyView()
        }
    }
}

// MARK: - Простые реализации компонентов

private struct SimpleBlockView: View {
    let text: String
    let style: String
    
    var body: some View {
        Text(text)
            .padding()
            .background(backgroundColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch style {
        case "info": return Color.blue.opacity(0.1)
        case "warning": return Color.orange.opacity(0.1)
        case "tip": return Color.green.opacity(0.1)
        case "quote": return Color.gray.opacity(0.1)
        default: return Color.gray.opacity(0.1)
        }
    }
}

private struct SimpleChecklistView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack {
                    Image(systemName: (item.isDone ?? false) ? "checkmark.circle.fill" : "circle")
                    Text(item.text ?? "")
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct SimpleFAQView: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Q: \(question)")
                .font(.headline)
            Text("A: \(answer)")
                .font(.body)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct SimpleLinksView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
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
}

private struct SimpleImageView: View {
    let urlString: String?
    let base64: String?
    let caption: String?
    
    var body: some View {
        VStack(spacing: 8) {
            // Простая заглушка для изображения
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            if let c = caption, !c.isEmpty {
                Text(c)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SimpleListView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text("• \(item.text ?? "")")
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
    }
}
