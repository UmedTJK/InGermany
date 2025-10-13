//
//  ArticleEditorViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

import Foundation

struct ArticleDocument: Codable {
    let title: String
    let blocks: [ArticleSection]
}

@MainActor
final class ArticleEditorViewModel: ObservableObject {
    // MARK: - State
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
            newBlock = ArticleBlock(type: .checklist, payload: .checklist([ChecklistEntry(text: "", isDone: false)]))
        case .faq:
            newBlock = ArticleBlock(type: .faq, payload: .faq(question: "", answer: ""))
        case .links:
            newBlock = ArticleBlock(type: .links, payload: .links([LinkEntry(title: "", articleId: "")]))
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

    // MARK: - Export (with title + file save + pretty print)

    @discardableResult
    func exportToJSON() throws -> Data {
        let document = ArticleDocument(title: title, blocks: toSections())
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]

        let data = try encoder.encode(document)

        // ✅ Pretty print
        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== Article JSON ===")
            print(jsonString)
            print("=====================")
        }

        // ✅ Save to Documents/article.json
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
    
    // MARK: - Export URL helper
    func exportedFileURL() -> URL? {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsURL.appendingPathComponent("article.json")
        }
        return nil
    }



    // MARK: - Convert to ArticleRenderer model
    func toSections() -> [ArticleSection] {
        blocks.map { block in
            switch block.payload {
            case .content(let text):
                return ArticleSection(type: block.type.rawValue,
                                      content: text,
                                      items: nil,
                                      question: nil,
                                      answer: nil)
            case .list(let items):
                let mapped = items.map { ArticleItem(text: $0, isDone: nil, title: nil, articleId: nil) }
                return ArticleSection(type: "list", content: nil, items: mapped, question: nil, answer: nil)
            case .checklist(let entries):
                let mapped = entries.map { ArticleItem(text: $0.text, isDone: $0.isDone, title: nil, articleId: nil) }
                return ArticleSection(type: "checklist", content: nil, items: mapped, question: nil, answer: nil)
            case .faq(let q, let a):
                return ArticleSection(type: "faq", content: nil, items: nil, question: q, answer: a)
            case .links(let links):
                let mapped = links.map { ArticleItem(text: nil, isDone: nil, title: $0.title, articleId: $0.articleId) }
                return ArticleSection(type: "links", content: nil, items: mapped, question: nil, answer: nil)
            }
        }
    }
}
