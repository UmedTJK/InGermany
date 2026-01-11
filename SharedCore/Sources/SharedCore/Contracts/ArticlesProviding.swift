import Foundation

public protocol ArticlesProviding: Sendable {
    func fetchAllArticles() async throws -> [Article]
    func fetchArticle(id: ArticleID) async throws -> Article?
    func searchArticles(query: String) async throws -> [Article]
}

