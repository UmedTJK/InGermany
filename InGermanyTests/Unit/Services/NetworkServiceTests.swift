import XCTest
@testable import InGermany

final class NetworkServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    private func makeServiceFastRetry() -> NetworkService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return NetworkService(
            session: URLSession(configuration: config),
            maxRetryAttempts: 3,
            baseRetryDelay: 1_000_000, // 1ms
            sleeper: { _ in }
        )
    }

    private func makeServiceRealSleepRetry(baseDelay: UInt64 = 80_000_000) -> NetworkService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return NetworkService(
            session: URLSession(configuration: config),
            maxRetryAttempts: 3,
            baseRetryDelay: baseDelay,
            sleeper: { try await Task.sleep(nanoseconds: $0) }
        )
    }

    struct Dummy: Codable, Equatable {
        let v: Int
    }

    func testLoadJSON_networkSuccess_decodes() async throws {
        let service = makeServiceFastRetry()
        service.clearCache()

        let file = "dummy-\(UUID().uuidString).json"
        let body = try JSONEncoder().encode(Dummy(v: 7))

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, body)
        }

        let result: Dummy = try await service.loadJSON(from: file)
        XCTAssertEqual(result, Dummy(v: 7))
        XCTAssertEqual(MockURLProtocol.requestCount, 1)
    }

    func testLoadJSON_retryOn500_thenSuccess() async throws {
        let service = makeServiceFastRetry()
        service.clearCache()

        let file = "retry-\(UUID().uuidString).json"
        let okBody = try JSONEncoder().encode(Dummy(v: 42))

        var attempt = 0
        MockURLProtocol.requestHandler = { request in
            attempt += 1
            if attempt < 3 {
                let r = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
                return (r, Data())
            } else {
                let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
                return (r, okBody)
            }
        }

        let result: Dummy = try await service.loadJSON(from: file)
        XCTAssertEqual(result, Dummy(v: 42))
        XCTAssertEqual(MockURLProtocol.requestCount, 3, "Should retry twice then succeed on 3rd attempt")
    }

    func testLoadJSON_invalidJSON_throwsDecodeError() async {
        let service = makeServiceFastRetry()
        service.clearCache()

        let file = "bad-\(UUID().uuidString).json"
        let badBody = Data("{not_json}".utf8)

        MockURLProtocol.requestHandler = { request in
            let r = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
            return (r, badBody)
        }

        do {
            let _: Dummy = try await service.loadJSON(from: file)
            XCTFail("Expected decode error")
        } catch {
            // OK
        }
    }

    func testLoadJSON_cancellationStopsRetries() async {
        let service = makeServiceRealSleepRetry(baseDelay: 200_000_000) // 200ms
        service.clearCache()

        MockURLProtocol.responseDelayNanoseconds = 2_000_000_000 // 2s

        let file = "cancel-\(UUID().uuidString).json"

        let firstRequest = expectation(description: "first request started")
        firstRequest.assertForOverFulfill = false

        var didFulfill = false
        MockURLProtocol.onRequest = {
            if !didFulfill {
                didFulfill = true
                firstRequest.fulfill()
            }
        }

        MockURLProtocol.requestHandler = { request in
            // Always 500 => would retry, but we cancel as soon as the first request starts.
            let r = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (r, Data())
        }

        let task = Task {
            let _: Dummy = try await service.loadJSON(from: file)
        }

        await fulfillment(of: [firstRequest], timeout: 2.0)
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
            // OK
        } catch {
            // Some implementations may surface cancellation wrapped; still acceptable for this test.
        }

        XCTAssertEqual(MockURLProtocol.requestCount, 1, "Cancellation should stop retries before a second request")
    }

    func testLoadJSON_parallelRequests_stabilityUnderLoad() async throws {
        let service = makeServiceFastRetry()
        service.clearCache()

        let file = "parallel-\(UUID().uuidString).json"
        let body = try JSONEncoder().encode(Dummy(v: 99))

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, body)
        }

        try await withThrowingTaskGroup(of: Dummy.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try await service.loadJSON(from: file)
                }
            }

            var results: [Dummy] = []
            for try await value in group {
                results.append(value)
            }

            XCTAssertEqual(results.count, 20)
            XCTAssertTrue(results.allSatisfy { $0 == Dummy(v: 99) })
        }

        XCTAssertEqual(MockURLProtocol.requestCount, 1, "Strict in-flight dedupe should perform only one network request")
    }
}

// MARK: - URLProtocol Mock

final class MockURLProtocol: URLProtocol {

    private static let lock = NSLock()

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))? {
        get {
            lock.lock(); defer { lock.unlock() }
            return _requestHandler
        }
        set {
            lock.lock(); defer { lock.unlock() }
            _requestHandler = newValue
        }
    }

    static var onRequest: (() -> Void)? {
        get {
            lock.lock(); defer { lock.unlock() }
            return _onRequest
        }
        set {
            lock.lock(); defer { lock.unlock() }
            _onRequest = newValue
        }
    }

    static private(set) var requestCount: Int {
        get {
            lock.lock(); defer { lock.unlock() }
            return _requestCount
        }
        set {
            lock.lock(); defer { lock.unlock() }
            _requestCount = newValue
        }
    }

    static var responseDelayNanoseconds: UInt64 {
        get {
            lock.lock(); defer { lock.unlock() }
            return _responseDelayNanoseconds
        }
        set {
            lock.lock(); defer { lock.unlock() }
            _responseDelayNanoseconds = newValue
        }
    }

    private static var _requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    private static var _onRequest: (() -> Void)?
    private static var _requestCount: Int = 0
    private static var _responseDelayNanoseconds: UInt64 = 0

    static func reset() {
        lock.lock(); defer { lock.unlock() }
        _requestHandler = nil
        _requestCount = 0
        _onRequest = nil
        _responseDelayNanoseconds = 0
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    private var delayedWorkItem: DispatchWorkItem?

    override func startLoading() {
        Self.lock.lock()
        Self._requestCount += 1
        let handler = Self._requestHandler
        let onRequest = Self._onRequest
        let delay = Self._responseDelayNanoseconds
        Self.lock.unlock()

        onRequest?()

        guard let handler else {
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        let deliver: () -> Void = { [weak self] in
            guard let self else { return }
            do {
                let (response, data) = try handler(self.request)
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            } catch {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }

        if delay > 0 {
            let item = DispatchWorkItem(block: deliver)
            delayedWorkItem = item
            DispatchQueue.global().asyncAfter(deadline: .now() + .nanoseconds(Int(delay)), execute: item)
        } else {
            deliver()
        }
    }

    override func stopLoading() {
        delayedWorkItem?.cancel()
        delayedWorkItem = nil
    }
}
