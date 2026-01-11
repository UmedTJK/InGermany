//
//  ArticleEditorCoordinator.swift
//  InGermany
//
//  Created by SUM TJK on 11.01.26.
//
import Foundation
import ArticleKit
import SharedCore
import Combine


@MainActor
final class ArticleEditorCoordinator: ObservableObject {

    @Published var editorViewModel: ArticleEditorViewModel

    private let writer: ArticlesWriting

    init(
        document: ArticleDocument,
        writer: ArticlesWriting
    ) {
        self.editorViewModel = ArticleEditorViewModel(document: document)
        self.writer = writer
    }

    func save() async throws {
        // 1️⃣ Сохраняем локально (как и раньше)
        editorViewModel.saveDocument()

        // 2️⃣ Пишем в домен через SharedCore
        let article = mapToSharedCore(editorViewModel.document)
        try await writer.updateArticle(article)
    }
}
// MARK: - Mapping to SharedCore
private extension ArticleEditorCoordinator {

    func mapToSharedCore(_ document: ArticleDocument) -> Article {
        Article(
            id: ArticleID(document.id.uuidString),
            slug: makeSlug(from: document.title),
            title: LocalizedText(
                values: [
                    LocaleID("de"): document.title
                ]
            ),
            summary: nil,
            categoryIDs: [],
            tagIDs: [],
            blocks: [],
            status: .draft,
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: nil
        )
    }

    func makeSlug(from title: String) -> String {
        title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(
                of: "[^a-z0-9\\-]",
                with: "",
                options: .regularExpression
            )
    }
}
