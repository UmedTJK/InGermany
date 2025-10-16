//
//  ArticleEditorViewModel.swift
//  InGermany
//

import Foundation

struct ArticleDocument: Codable {
    let title: String
    let blocks: [ArticleSectionDTO] // ✅ используем DTO
}

@MainActor
final class ArticleEditorViewModel: ObservableObject, Identifiable {
    nonisolated let id = UUID()
    
    @Published var title: String
    @Published var blocks: [ArticleBlock]

    init(title: String = "", blocks: [ArticleBlock] = []) {
        self.title = title
        self.blocks = blocks
    }

    // MARK: - Mutations
    func addBlock(type: BlockType) {
        let newBlock: ArticleBlock
        switch type {
        case .paragraph, .info, .warning, .tip, .quote:
            newBlock = ArticleBlock(type: type, payload: .content(""))
        case .list:
            newBlock = ArticleBlock(type: .list, payload: .list([""]))
        case .checklist:
            newBlock = ArticleBlock(type: .checklist,
                                    payload: .checklist([ChecklistEntry(text: "", isDone: false)]))
        case .faq:
            newBlock = ArticleBlock(type: .faq,
                                    payload: .faq(question: "", answer: ""))
        case .links:
            newBlock = ArticleBlock(type: .links,
                                    payload: .links([LinkEntry(title: "", articleId: "")]))
        case .image: // ✅ image block
            newBlock = ArticleBlock(type: .image,
                                    payload: .image(url: nil, caption: "", base64: nil))
        }
        blocks.append(newBlock)
    }

    func deleteBlock(id: UUID) {
        if let idx = blocks.firstIndex(where: { $0.id == id }) {
            blocks.remove(at: idx)
        }
    }

    func moveBlock(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Export
    @discardableResult
    func exportToJSON() throws -> Data {
        let document = ArticleDocument(title: title, blocks: toSections())
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]

        let data = try encoder.encode(document)

        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== Article JSON ===\n\(jsonString)\n=====================")
        }

        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent("article.json")
            do {
                try data.write(to: fileURL, options: .atomic)
                print("📂 JSON saved to: \(fileURL.path)")
            } catch {
                print("⚠️ Failed to save JSON: \(error)")
            }
        }
        return data
    }
    
    func exportedFileURL() -> URL? {
        let fm = FileManager.default
        if let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsURL.appendingPathComponent("article.json")
        }
        return nil
    }

    // MARK: - Convert to DTO
    func toSections() -> [ArticleSectionDTO] {
        blocks.map { block in
            switch block.payload {
            case .content(let text):
                return ArticleSectionDTO(type: block.type.rawValue,
                                         content: text,
                                         items: nil,
                                         question: nil,
                                         answer: nil,
                                         url: nil,
                                         caption: nil,
                                         base64: nil)
            case .list(let items):
                let mapped = items.map { ArticleItemDTO(text: $0, isDone: nil, title: nil, articleId: nil) }
                return ArticleSectionDTO(type: "list", content: nil, items: mapped,
                                         question: nil, answer: nil,
                                         url: nil, caption: nil, base64: nil)
            case .checklist(let entries):
                let mapped = entries.map { ArticleItemDTO(text: $0.text, isDone: $0.isDone,
                                                          title: nil, articleId: nil) }
                return ArticleSectionDTO(type: "checklist", content: nil, items: mapped,
                                         question: nil, answer: nil,
                                         url: nil, caption: nil, base64: nil)
            case .faq(let q, let a):
                return ArticleSectionDTO(type: "faq", content: nil, items: nil,
                                         question: q, answer: a,
                                         url: nil, caption: nil, base64: nil)
            case .links(let links):
                let mapped = links.map { ArticleItemDTO(text: nil, isDone: nil,
                                                        title: $0.title, articleId: $0.articleId) }
                return ArticleSectionDTO(type: "links", content: nil, items: mapped,
                                         question: nil, answer: nil,
                                         url: nil, caption: nil, base64: nil)
            case .image(let url, let caption, let base64): // ✅ image
                return ArticleSectionDTO(type: "image", content: nil, items: nil,
                                         question: nil, answer: nil,
                                         url: url, caption: caption, base64: base64)
            }
        }
    }
    
    // MARK: - Import
    func importFromJSON(_ data: Data) throws {
        let decoder = JSONDecoder()
        let document = try decoder.decode(ArticleDocument.self, from: data)
        self.title = document.title
        self.blocks = document.blocks.map { ArticleBlock.fromSection($0) }
    }

    func loadFromFile(url: URL) throws {
        let data = try Data(contentsOf: url)
        try importFromJSON(data)
    }
}

// MARK: - Hashable & Equatable
extension ArticleEditorViewModel: Hashable {
    nonisolated static func == (lhs: ArticleEditorViewModel, rhs: ArticleEditorViewModel) -> Bool {
        lhs.id == rhs.id
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
