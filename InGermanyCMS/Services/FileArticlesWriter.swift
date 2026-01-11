//
//  FileArticlesWriter.swift
//  InGermany
//
//  Created by SUM TJK on 11.01.26.
//
import Foundation
import SharedCore

@MainActor
final class FileArticlesWriter: ArticlesWriting {

    private let directoryURL: URL
    private let encoder: JSONEncoder

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
    }

    func createArticle(_ article: Article) async throws {
        try write(article)
    }

    func updateArticle(_ article: Article) async throws {
        try write(article)
    }

    func deleteArticle(id: ArticleID) async throws {
        let url = fileURL(for: id)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Private

    private func write(_ article: Article) throws {
        try ensureDirectory()
        let data = try encoder.encode(article)
        try data.write(to: fileURL(for: article.id), options: .atomic)
    }

    private func fileURL(for id: ArticleID) -> URL {
        directoryURL.appendingPathComponent("\(id.rawValue).json")
    }

    private func ensureDirectory() throws {
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }
    }
}

