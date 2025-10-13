//
//  ArticleEditorViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

import Foundation

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

    // MARK: - Export (strict JSON)
    func exportToJSON() throws -> Data {
        let sections = toSections()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return try encoder.encode(sections)
    }

    // MARK: - Convert to ArticleRenderer model (for live preview)
    func toSections() -> [ArticleSection] {
        blocks.map { block in
            switch block.payload {
            case .content(let text):
                return ArticleSection(
                    type: block.type.rawValue,
                    content: text,
                    items: nil,
                    question: nil,
                    answer: nil
                )
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
