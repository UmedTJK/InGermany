import Foundation
@testable import InGermany

/// Mock for NetworkServiceProtocol (used by DataService actor).
final class MockNetworkService: NetworkServiceProtocol {
    enum MockError: Error { case notConfigured }

    struct ResponseBox {
        let data: Data
        let source: NetworkDataSource
    }

    // file -> response
    private var responses: [String: ResponseBox] = [:]
    // file -> error
    private var errors: [String: Error] = [:]

    // call counters
    private(set) var loadJSONCalls: [String: Int] = [:]
    private(set) var loadJSONWithSourceCalls: [String: Int] = [:]
    private(set) var clearCacheCallCount: Int = 0

    // Optional artificial delay to make async scheduling observable
    var delayNanos: UInt64 = 0

    func setResponse<T: Encodable>(for file: String, value: T, source: NetworkDataSource) {
        let data = (try? JSONEncoder().encode(value)) ?? Data()
        responses[file] = ResponseBox(data: data, source: source)
    }

    func setRawResponse(for file: String, data: Data, source: NetworkDataSource) {
        responses[file] = ResponseBox(data: data, source: source)
    }

    func setError(for file: String, error: Error) {
        errors[file] = error
    }

    func loadJSON<T: Decodable>(from file: String) async throws -> T {
        loadJSONCalls[file, default: 0] += 1
        if delayNanos > 0 { try await Task.sleep(nanoseconds: delayNanos) }

        if let err = errors[file] { throw err }
        guard let box = responses[file] else { throw MockError.notConfigured }

        return try JSONDecoder().decode(T.self, from: box.data)
    }

    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, NetworkDataSource) {
        loadJSONWithSourceCalls[file, default: 0] += 1
        if delayNanos > 0 { try await Task.sleep(nanoseconds: delayNanos) }

        if let err = errors[file] { throw err }
        guard let box = responses[file] else { throw MockError.notConfigured }

        let decoded = try JSONDecoder().decode(T.self, from: box.data)
        return (decoded, box.source)
    }

    func clearCache() {
        clearCacheCallCount += 1
    }
}
