import SwiftUI

public struct ArticleRenderer: View {
    let sections: [ArticleSectionDTO]
    
    public init(sections: [ArticleSectionDTO]) {
        self.sections = sections
    }
    
    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(sections) { section in
                SectionView(section: section)
            }
        }
    }
}

// MARK: - Section Views

private struct SectionView: View {
    let section: ArticleSectionDTO
    
    var body: some View {
        switch section.type {
        case "paragraph":
            ParagraphView(content: section.content ?? "")
        case "info":
            InfoView(content: section.content ?? "")
        case "warning":
            WarningView(content: section.content ?? "")
        case "tip":
            TipView(content: section.content ?? "")
        case "quote":
            QuoteView(content: section.content ?? "")
        case "checklist":
            ChecklistView(items: section.items ?? [])
        case "faq":
            FAQView(section: section)
        case "list":
            ListView(items: section.items ?? [])
        case "links":
            LinksView(items: section.items ?? [])
        case "image":
            // ✅ ОБНОВЛЯЕМ ДЛЯ ПОДДЕРЖКИ РАСШИРЕННЫХ ИЗОБРАЖЕНИЙ
            EnhancedImageView(section: section)
        default:
            UnknownView(section: section)
        }
    }
}

// MARK: - Enhanced Image Section

private struct EnhancedImageView: View {
    let section: ArticleSectionDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Отображаем изображение если есть путь
            if let imagePath = section.imageData?.imagePath,
               let image = loadImage(from: imagePath) {
                StableImageContainer(aspectRatio: Metrics.remoteImageAspectRatio) {
                    image
                        .resizable()
                        .scaledToFill()
                }
            } else if let content = section.content, !content.isEmpty {
                // Fallback: старая логика с URL
                if let url = URL(string: content) {
                    StableRemoteImage(url: url, aspectRatio: Metrics.remoteImageAspectRatio)
                } else {
                    // Fallback: заглушка
                    placeholderImage
                }
            } else {
                // Пустой блок изображения
                placeholderImage
            }
            
            // Отображаем подпись если есть
            if let caption = section.imageData?.caption, !caption.isEmpty {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var placeholderImage: some View {
        StableImageContainer(aspectRatio: Metrics.remoteImageAspectRatio) {
            ZStack {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.14))

                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.softLight)

                VStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.system(size: Metrics.placeholderIconSize, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("Изображение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // ✅ ФУНКЦИЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЯ ИЗ ФАЙЛА
    private func loadImage(from path: String) -> Image? {
        #if os(macOS)
        guard let nsImage = NSImage(contentsOfFile: path) else { return nil }
        return Image(nsImage: nsImage)
        #else
        // Для iOS можно добавить UIImage логику
        return nil
        #endif
    }
    private enum Metrics {
        static let remoteImageAspectRatio: CGFloat = 16.0 / 9.0
        static let placeholderIconSize: CGFloat = 34
        static let fadeInDuration: CGFloat = 0.18
        static let cornerRadius: CGFloat = 12
    }

    /// A stable container that reserves layout space before the image loads.
    private struct StableImageContainer<Content: View>: View {
        let aspectRatio: CGFloat
        @ViewBuilder var content: () -> Content

        var body: some View {
            Rectangle()
                .fill(Color.clear)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay(content())
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
        }
    }

    /// Remote image with a premium placeholder, no layout jumps, and a subtle fade-in.
    private struct StableRemoteImage: View {
        let url: URL
        let aspectRatio: CGFloat

        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        @State private var didAppearLoadedImage: Bool = false

        var body: some View {
            StableImageContainer(aspectRatio: aspectRatio) {
                AsyncImage(url: url, transaction: Transaction(animation: nil)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .opacity(didAppearLoadedImage ? 1 : 0)
                            .onAppear {
                                guard !didAppearLoadedImage else { return }
                                if reduceMotion {
                                    didAppearLoadedImage = true
                                } else {
                                    withAnimation(.easeOut(duration: Metrics.fadeInDuration)) {
                                        didAppearLoadedImage = true
                                    }
                                }
                            }

                    case .failure:
                        placeholder

                    case .empty:
                        placeholder

                    @unknown default:
                        placeholder
                    }
                }
            }
        }

        private var placeholder: some View {
            ZStack {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.14))

                // Subtle sheen to feel “designed” without heavy shimmer.
                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.softLight)

                VStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.system(size: Metrics.placeholderIconSize, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("Изображение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Basic Text Sections

private struct ParagraphView: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InfoView: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
            Text(content)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct WarningView: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text(content)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct TipView: View {
    let content: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "lightbulb")
                .foregroundColor(.green)
            Text(content)
                .font(.body)
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct QuoteView: View {
    let content: String
    
    var body: some View {
        // ✅ ИСПРАВЛЕННЫЕ КАВЫЧКИ
        Text("“\(content)”")
            .font(.body.italic())
            .foregroundColor(.secondary)
            .padding(.leading, 16)
            .overlay(
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 4)
                    .padding(.vertical, 4),
                alignment: .leading
            )
    }
}

// MARK: - List Sections

private struct ChecklistView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                HStack(alignment: .top) {
                    Image(systemName: item.isCompleted == true ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isCompleted == true ? .green : .gray)
                    Text(item.text)
                        .font(.body)
                        .strikethrough(item.isCompleted == true)
                    Spacer()
                }
            }
        }
    }
}

private struct ListView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(item.text)
                        .font(.body)
                    Spacer()
                }
            }
        }
    }
}

private struct LinksView: View {
    let items: [ArticleItemDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                if let url = URL(string: item.text) {
                    Link(destination: url) {
                        HStack {
                            Text(item.text)
                                .font(.body)
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                } else {
                    Text(item.text)
                        .font(.body)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - FAQ Section

private struct FAQView: View {
    let section: ArticleSectionDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Первый элемент - вопрос (content), остальные - ответы (items)
            if let question = section.content, !question.isEmpty {
                Text(question)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(section.items ?? []) { item in
                Text(item.text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Unknown Section Fallback

private struct UnknownView: View {
    let section: ArticleSectionDTO
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Unknown section type: \(section.type)")
                .font(.headline)
                .foregroundColor(.red)
            if let content = section.content {
                Text(content)
                    .font(.body)
            }
            if let items = section.items {
                ForEach(items) { item in
                    Text("• \(item.text)")
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ArticleRenderer(sections: [
            ArticleSectionDTO(type: "paragraph", content: "Это обычный параграф текста."),
            ArticleSectionDTO(type: "info", content: "Это информационный блок."),
            ArticleSectionDTO(type: "warning", content: "Это предупреждение!"),
            ArticleSectionDTO(type: "tip", content: "Это полезный совет."),
            ArticleSectionDTO(type: "quote", content: "Это цитата от известного человека."),
            ArticleSectionDTO(type: "checklist", items: [
                ArticleItemDTO(text: "Задача 1", isCompleted: true),
                ArticleItemDTO(text: "Задача 2", isCompleted: false),
                ArticleItemDTO(text: "Задача 3", isCompleted: false)
            ]),
            ArticleSectionDTO(type: "list", items: [
                ArticleItemDTO(text: "Элемент списка 1"),
                ArticleItemDTO(text: "Элемент списка 2"),
                ArticleItemDTO(text: "Элемент списка 3")
            ]),
            ArticleSectionDTO(type: "faq", content: "Часто задаваемый вопрос?", items: [
                ArticleItemDTO(text: "Ответ на часто задаваемый вопрос.")
            ]),
            // ✅ ДОБАВЛЯЕМ ПРИМЕР ИЗОБРАЖЕНИЯ С ДАННЫМИ
            ArticleSectionDTO(
                type: "image",
                content: "Пример изображения",
                imageData: ImageData(
                    caption: "Это тестовая подпись к изображению",
                    altText: "Описание изображения для доступности"
                )
            )
        ])
        .padding()
    }
}
