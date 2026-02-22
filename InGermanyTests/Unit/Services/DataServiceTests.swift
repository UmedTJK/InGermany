import Foundation
import XCTest
@testable import InGermany

final class DataServiceTests: XCTestCase {

    // MARK: - Test doubles

    private final class TestNetworkService: NetworkServiceProtocol {
        enum TestError: Error { case notConfigured }

        var delayNanos: UInt64 = 0

        // Per-file configuration
        private var dataByFile: [String: Data] = [:]
        private var sourceByFile: [String: NetworkDataSource] = [:]
        private var errorByFile: [String: Error] = [:]

        // Call counters
        var loadJSONCalls: [String: Int] = [:]
        var loadJSONWithSourceCalls: [String: Int] = [:]

        func setResponse<T: Encodable>(for file: String, value: T, source: NetworkDataSource = .network) {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            dataByFile[file] = try? encoder.encode(value)
            sourceByFile[file] = source
            errorByFile[file] = nil
        }

        func setError(for file: String, error: Error) {
            errorByFile[file] = error
        }

        func loadJSON<T: Decodable>(from file: String) async throws -> T {
            loadJSONCalls[file, default: 0] += 1
            if delayNanos > 0 { try await Task.sleep(nanoseconds: delayNanos) }

            if let err = errorByFile[file] { throw err }
            guard let data = dataByFile[file] else { throw TestError.notConfigured }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        }

        func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, NetworkDataSource) {
            loadJSONWithSourceCalls[file, default: 0] += 1
            if delayNanos > 0 { try await Task.sleep(nanoseconds: delayNanos) }

            if let err = errorByFile[file] { throw err }
            guard let data = dataByFile[file] else { throw TestError.notConfigured }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(T.self, from: data)
            return (decoded, sourceByFile[file] ?? .network)
        }

        func clearCache() {
            // no-op for tests
        }
    }

    // MARK: - Helpers

    private func makeArticles(_ n: Int) -> [Article] {
        (0..<n).map { i in
            Article(
                id: "\(i)",
                title: ["en": "A\(i)"],
                content: ["en": "Body \(i)"],
                categoryId: "cat",
                tags: []
            )
        }
    }

    // MARK: - Tests

    func testLoadArticles_returnsFromCache_evenIfNetworkFails() async {
        let network = TestNetworkService()
        network.setError(for: "articles.json", error: TestNetworkService.TestError.notConfigured)

        let cache = CacheService()
        let sut = DataService(networkService: network, cacheManager: cache)

        let expected = makeArticles(3)
        await cache.set("articles", value: expected)

        let result = await sut.loadArticles()
        XCTAssertEqual(result.count, expected.count)
        XCTAssertEqual(result.first?.localizedTitle(for: "en"), expected.first?.localizedTitle(for: "en"))
    }

    func testLoadArticles_schedulesBackgroundRefresh_dedupedToSingleInFlight() async {
        let network = TestNetworkService()
        network.delayNanos = 150_000_000 // 0.15s
        network.setResponse(for: "articles.json", value: makeArticles(2), source: .network)

        let cache = CacheService()
        let sut = DataService(networkService: network, cacheManager: cache)

        // Seed cache so loadArticles returns immediately and schedules refresh.
        await cache.set("articles", value: makeArticles(1))

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<25 {
                group.addTask {
                    _ = await sut.loadArticles()
                }
            }
            await group.waitForAll()
        }

        // Wait briefly for the refresh task to hit the network.
        let deadline = Date().addingTimeInterval(2.0)
        while Date() < deadline {
            let calls = network.loadJSONWithSourceCalls["articles.json"] ?? 0
            if calls >= 1 { break }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        XCTAssertEqual(network.loadJSONWithSourceCalls["articles.json"] ?? 0, 1, "Refresh must be deduped to 1 in-flight task")
    }

    func testRefreshArticlesIfNeeded_updatesOnlyWhenSourceIsNetwork() async {
        let network = TestNetworkService()
        let cache = CacheService()
        let sut = DataService(networkService: network, cacheManager: cache)

        let old = makeArticles(1)
        await cache.set("articles", value: old)

        // Case 1: source != .network -> should NOT update
        let newer = makeArticles(5)
        network.setResponse(for: "articles.json", value: newer, source: .fileCache)

        _ = await sut.loadArticles()
        try? await Task.sleep(nanoseconds: 300_000_000)

        let after1 = await sut.loadArticles()
        XCTAssertEqual(after1.count, old.count, "Should NOT update when source != .network")

        // Case 2: source == .network -> should update
        network.setResponse(for: "articles.json", value: newer, source: .network)

        _ = await sut.loadArticles()
        try? await Task.sleep(nanoseconds: 300_000_000)

        let after2 = await sut.loadArticles()
        XCTAssertEqual(after2.count, newer.count, "Should update when source == .network")
    }
}
