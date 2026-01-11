import Foundation

public protocol ArticlesWriting: Sendable {
    func createArticle(_ article: Article) async throws
    func updateArticle(_ article: Article) async throws
    func deleteArticle(id: ArticleID) async throws
}

