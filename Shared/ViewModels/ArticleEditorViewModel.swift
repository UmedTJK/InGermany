//
//  ArticleEditorViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//
import Foundation

@MainActor
public final class ArticleEditorViewModel: ObservableObject {
    @Published public var title: String
    @Published public var blocks: [ArticleBlock]

    public init(title: String = "", blocks: [ArticleBlock] = []) {
        self.title = title
        self.blocks = blocks
    }

    // MARK: Mutations
    public func addBlock(type: BlockType) {
        blocks.append(ArticleBlock(type: type))
    }

    public func deleteBlock(id: UUID) {
        if let idx = blocks.firstIndex(where: { $0.id == id }) {
            blocks.remove(at: idx)
        }
    }

    public func moveBlock(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: Export → JSON строго по контракту ArticleRenderer
    public func exportToJSON() throws -> Data {
        let sections: [ArticleSectionDTO] = blocks.map { block in
            switch block.type {
            case .paragraph, .info, .warning, .tip, .quote:
                return ArticleSectionDTO(
                    type: block.type.rawValue,
                    content: block.content,
                    items: nil,
                    question: nil,
                    answer: nil
                )

            case .list:
                // Каждая строка content → item.text
                let items = block.content
                    .split(whereSeparator: \.isNewline)
                    .map { ArticleItemDTO(text: String($0), isDone: nil, title: nil, articleId: nil) }
                return ArticleSectionDTO(type: "list", content: nil, items: items, question: nil, answer: nil)

            case .checklist:
                // Каждая строка content → item.text (isDone = false по умолчанию)
                let items = block.content
                    .split(whereSeparator: \.isNewline)
                    .map { ArticleItemDTO(text: String($0), isDone: false, title: nil, articleId: nil) }
                return ArticleSectionDTO(type: "checklist", content: nil, items: items, question: nil, answer: nil)

            case .faq:
                return ArticleSectionDTO(
                    type: "faq",
                    content: nil,
                    items: nil,
                    question: block.extra?["question"],
                    answer: block.extra?["answer"]
                )
            }
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        return try encoder.encode(sections)
    }
}

