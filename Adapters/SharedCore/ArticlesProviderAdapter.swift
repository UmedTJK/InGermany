import Foundation
import SharedCore

final class ArticlesProviderAdapter: ArticlesProviding, @unchecked Sendable {

    private let repo: ArticlesRepositoryProtocol

    init(repo: ArticlesRepositoryProtocol) {
        self.repo = repo
    }

    // MARK: - ArticlesProviding

    func fetchAllArticles() async throws -> [SharedCore.Article] {
        let articles = await repo.loadArticles()
        return articles.map { mapToSharedCore(from: $0) }
    }

    func fetchArticle(id: ArticleID) async throws -> SharedCore.Article? {
        let articles = await repo.loadArticles()
        return articles
            .first { $0.id == id.rawValue }
            .map { mapToSharedCore(from: $0) }
    }

    func searchArticles(query: String) async throws -> [SharedCore.Article] {
        // Минимальная реализация: поиск по id
        let articles = await repo.loadArticles()
        return articles
            .filter { $0.id.localizedCaseInsensitiveContains(query) }
            .map { mapToSharedCore(from: $0) }
    }
}

// MARK: - Minimal mapping (ONLY guaranteed fields)

private func mapToSharedCore(from a: Article) -> SharedCore.Article {
    // title у тебя: [String: String]
    // берём любое доступное значение, иначе fallback на id
    let titleValue = a.title.values.first ?? a.id

    return SharedCore.Article(
        id: ArticleID(a.id),
        slug: a.id,
        title: LocalizedText(values: [
            LocaleID("de-DE"): titleValue
        ]),
        summary: nil,
        categoryIDs: [],
        tagIDs: [],
        blocks: [],
        status: .published,
        createdAt: Date(),
        updatedAt: Date(),
        publishedAt: nil
    )
}
