//
//  NetworkService.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

import Foundation

/// Service responsible for loading JSON data with OFFLINE-FIRST strategy.
/// Uses: Bundle → File Cache → Network (async refresh)
final class NetworkService {
    typealias Sleeper = @Sendable (_ nanoseconds: UInt64) async throws -> Void
    
    private let logger = AppLogger.logger(for: .network)
    private let metrics: any NetworkMetricsCollecting
    
    private actor RefreshRegistry {
        private var tasks: [String: Task<Void, Never>] = [:]

        func getOrCreateTask(
            for key: String,
            create: @Sendable () -> Task<Void, Never>
        ) -> (task: Task<Void, Never>, created: Bool) {
            if let existing = tasks[key] {
                return (existing, false)
            }
            let task = create()
            tasks[key] = task
            return (task, true)
        }

        func removeTask(for key: String) {
            tasks[key] = nil
        }

        func cancelAll() {
            for (_, t) in tasks { t.cancel() }
            tasks.removeAll()
        }
        
        func hasTask(for key: String) -> Bool {
            tasks[key] != nil
        }
    }
    
    private actor LoadRegistry {
        private struct Entry {
            let task: Task<Data, Error>
            var waiters: Int
        }

        private var entries: [String: Entry] = [:]

        func acquireTask(
            for key: String,
            create: @Sendable () -> Task<Data, Error>
        ) -> (task: Task<Data, Error>, deduped: Bool) {
            if var entry = entries[key] {
                entry.waiters += 1
                entries[key] = entry
                return (entry.task, true)
            }

            let task = create()
            entries[key] = Entry(task: task, waiters: 1)
            return (task, false)
        }

        func cancelIfOnlyWaiter(for key: String) {
            guard let entry = entries[key] else { return }
            // If there is only one waiter (the caller), cancel immediately.
            if entry.waiters <= 1 {
                entry.task.cancel()
                entries[key] = nil
            }
        }

        func releaseWaiter(for key: String) {
            guard var entry = entries[key] else { return }
            entry.waiters -= 1
            if entry.waiters <= 0 {
                entries[key] = nil
            } else {
                entries[key] = entry
            }
        }

        func cancelAll() {
            for (_, entry) in entries { entry.task.cancel() }
            entries.removeAll()
        }
        
        func hasEntry(for key: String) -> Bool {
            entries[key] != nil
        }
    }

    /// Base URL for remote JSON files (GitHub raw). Must end with a slash.
    private let baseURL: URL
    
    // MARK: - In-flight refresh dedup (one per file)
    private let refreshRegistry = RefreshRegistry()
    private let loadRegistry = LoadRegistry()
    
    private func scheduleRefresh(file: String) {
        Task(priority: .utility) { [weak self] in
            guard let self else { return }
            if Task.isCancelled { return }
            await self.metrics.increment(.refresh_scheduled, file: file)

            let result = await self.refreshRegistry.getOrCreateTask(for: file) {
                Task(priority: .utility) { [weak self] in
                    guard let self else { return }
                    defer { Task { await self.refreshRegistry.removeTask(for: file) } }
                    await self.refreshFromNetwork(file: file)
                }
            }

            if !result.created {
                await self.metrics.increment(.refresh_dedupe_hit, file: file)
                return
            }

            _ = result.task
        }
    }
    
    /// Retry configuration
    private let maxRetryAttempts: Int
    private let baseRetryDelay: UInt64 // nanoseconds
    private let sleeper: Sleeper
    /// FileManager instance for file system operations.
    private let fileManager = FileManager.default
    /// Directory where cached JSON files are stored.
    private let cacheDirectory: URL

    /// URLSession used for network requests. Injectable for unit tests (e.g. MockURLProtocol).
    private let session: URLSession
    
    /// Initializes cache directory and network session.
    /// - Parameter session: Injectable session for unit tests (use URLSessionConfiguration with MockURLProtocol).
    init(
        session: URLSession = NetworkService.makeDefaultSession(),
        baseURL: URL = URL(string: "https://raw.githubusercontent.com/sumtjk/InGermany/main/Resources/")!,
        maxRetryAttempts: Int = 3,
        baseRetryDelay: UInt64 = 300_000_000,
        sleeper: @escaping Sleeper = { try await Task.sleep(nanoseconds: $0) },
        metrics: any NetworkMetricsCollecting = NoopNetworkMetricsCollector()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.maxRetryAttempts = maxRetryAttempts
        self.baseRetryDelay = baseRetryDelay
        self.sleeper = sleeper
        self.metrics = metrics

        // Создаем директорию для кэша
        let directories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = directories[0].appendingPathComponent("InGermanyCache")

        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create cache directory: \(String(describing: error), privacy: .public)")
        }
    }

    private static func makeDefaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0
        config.timeoutIntervalForResource = 2.0
        config.waitsForConnectivity = false
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }
    
    // MARK: - Основной API
    
    /// Loads and decodes a JSON file into a specified Decodable type with OFFLINE-FIRST strategy.
    /// Strategy: Bundle → File Cache → Network (with async refresh)
    func loadJSON<T: Decodable>(from file: String) async throws -> T {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            logger.debug("Loaded from bundle: \(file, privacy: .public)")
            await metrics.increment(.load_bundle_hit, file: file)
            scheduleRefresh(file: file)
            return try decodeData(bundleData)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            logger.debug("Loaded from file cache: \(file, privacy: .public)")
            await metrics.increment(.load_filecache_hit, file: file)
            scheduleRefresh(file: file)
            return try decodeData(cachedData)
        }
        
        // Шаг 3: Network
        logger.debug("Loading from network: \(file, privacy: .public)")
        await metrics.increment(.load_network_start, file: file)
        return try await loadFromNetwork(file: file)
    }
    
    /// Loads JSON with detailed source information for tracking
    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, NetworkDataSource) {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            logger.debug("Loaded from bundle: \(file, privacy: .public)")
            await metrics.increment(.load_bundle_hit, file: file)
            scheduleRefresh(file: file)
            let decoded: T = try decodeData(bundleData)
            return (decoded, .bundle)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            logger.debug("Loaded from file cache: \(file, privacy: .public)")
            await metrics.increment(.load_filecache_hit, file: file)
            scheduleRefresh(file: file)
            let decoded: T = try decodeData(cachedData)
            return (decoded, .fileCache)
        }
        
        // Шаг 3: Network
        logger.debug("Loading from network: \(file, privacy: .public)")
        await metrics.increment(.load_network_start, file: file)
        let decoded: T = try await loadFromNetwork(file: file)
        return (decoded, .network)
    }
    
    // MARK: - Приватные методы загрузки
    
    /// Executes a network request with exponential backoff retry.
    private func performWithRetry<T>(
        file: String,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var lastError: Error?
        
        while attempt < maxRetryAttempts {
            try Task.checkCancellation()
            do {
                return try await operation()
            } catch {
                // Cancellation can surface as CancellationError or as URLError.cancelled from URLSession.
                if error is CancellationError { throw error }
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    throw CancellationError()
                }
                if Task.isCancelled {
                    throw CancellationError()
                }

                lastError = error
                attempt += 1

                if attempt >= maxRetryAttempts {
                    break
                }

                // Retry scheduled (attempt is 1-based for observers).
                await metrics.increment(.retry_scheduled, file: file)

                let delay = baseRetryDelay * UInt64(pow(2.0, Double(attempt - 1)))
                try await sleeper(delay)
            }
        }
        
        await metrics.increment(.retry_exhausted, file: file)
        throw lastError ?? NetworkError.networkUnavailable
    }
    
    private func loadFromBundle(file: String) -> Data? {
        guard let bundleURL = Bundle.main.url(forResource: file, withExtension: nil) else {
            return nil
        }
        return try? Data(contentsOf: bundleURL)
    }
    
    private func loadFromCache(for file: String) -> Data? {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        return try? Data(contentsOf: cacheFile)
    }
    
    private func loadFromNetwork<T: Decodable>(file: String) async throws -> T {
        let data = try await loadDataFromNetworkDeduped(file: file)
        return try decodeData(data)
    }

    private func loadDataFromNetworkDeduped(file: String) async throws -> Data {
        let acquired = await loadRegistry.acquireTask(for: file) { [weak self] in
            Task<Data, Error>(priority: .userInitiated) {
                guard let self else { throw CancellationError() }
                return try await self.loadDataFromNetwork(file: file)
            }
        }

        if acquired.deduped {
            await metrics.increment(.load_network_dedupe_hit, file: file)
        }

        let task = acquired.task

        defer { Task { await loadRegistry.releaseWaiter(for: file) } }

        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            Task { [metrics] in
                await metrics.increment(.cancelled, file: file)
            }
            Task { await loadRegistry.cancelIfOnlyWaiter(for: file) }
        }
    }

    private func loadDataFromNetwork(file: String) async throws -> Data {
        let url = baseURL.appendingPathComponent(file)

        return try await performWithRetry(file: file) { [self] in
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad

            let (data, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                await metrics.increment(.load_network_failure, file: file)
                throw NetworkError.invalidResponse
            }

            self.saveToCache(data: data, for: file)
            await metrics.increment(.load_network_success, file: file)
            return data
        }
    }

    private func refreshFromNetwork(file: String) async {
        let url = baseURL.appendingPathComponent(file)

        do {
            try await performWithRetry(file: file) { [self] in
                var request = URLRequest(url: url)
                request.cachePolicy = .reloadIgnoringLocalCacheData
                request.timeoutInterval = 3.0

                let (data, response) = try await self.session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }

                self.saveToCache(data: data, for: file)
                return ()
            }

            logger.info("Background refresh succeeded: \(file, privacy: .public)")
            await metrics.increment(.refresh_success, file: file)
        } catch {
            logger.error("Background refresh failed after retry: \(String(describing: error), privacy: .public)")
            await metrics.increment(.refresh_failure, file: file)
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func saveToCache(data: Data, for file: String) {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        let directory = cacheFile.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        do {
            try data.write(to: cacheFile)
        } catch {
            logger.error("Failed to save file cache: \(String(describing: error), privacy: .public)")
            Task { [metrics] in
                await metrics.increment(.cache_save_failure, file: file)
            }
        }
    }
    
    private func decodeData<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Legacy API
    
    func loadJSONSync<T: Decodable>(from file: String, completion: @escaping (Result<T, Error>) -> Void) {
        Task {
            do {
                let result: T = try await loadJSON(from: file)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func clearCache() {
        // Cancel any in-flight refresh and load tasks
        Task {
            await refreshRegistry.cancelAll()
            await loadRegistry.cancelAll()
        }
    
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            logger.info("File cache cleared")
            Task { [metrics] in
                await metrics.increment(.cache_clear_success, file: "*")
            }
        } catch {
            logger.error("Failed to clear cache: \(String(describing: error), privacy: .public)")
            Task { [metrics] in
                await metrics.increment(.cache_clear_failure, file: "*")
            }
        }
    }
}

// MARK: - Вспомогательные типы

extension NetworkService {
    enum DataSource: String {
        case bundle = "bundle"
        case fileCache = "file_cache"
        case network = "network"
    }
    
    enum NetworkError: Error {
        case invalidResponse
        case networkUnavailable
    }
}

extension NetworkService: NetworkServiceProtocol {}
