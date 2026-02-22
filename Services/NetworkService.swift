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

    private actor RefreshRegistry {
        private var tasks: [String: Task<Void, Never>] = [:]

        func hasTask(for key: String) -> Bool {
            tasks[key] != nil
        }

        func setTask(_ task: Task<Void, Never>, for key: String) {
            tasks[key] = task
        }

        func removeTask(for key: String) {
            tasks[key] = nil
        }

        func cancelAll() {
            for (_, t) in tasks { t.cancel() }
            tasks.removeAll()
        }
    }

    /// Base URL for remote JSON files (GitHub raw). Must end with a slash.
    private let baseURL: URL
    
    // MARK: - In-flight refresh dedup (one per file)
    private let refreshRegistry = RefreshRegistry()
    
    private func scheduleRefresh(file: String) {
        Task(priority: .utility) { [weak self] in
            guard let self else { return }
            if Task.isCancelled { return }

            // Dedup inside actor registry.
            let alreadyInFlight = await self.refreshRegistry.hasTask(for: file)
            guard !alreadyInFlight else { return }

            let task = Task(priority: .utility) { [weak self] in
                guard let self else { return }
                defer { Task { await self.refreshRegistry.removeTask(for: file) } }
                await self.refreshFromNetwork(file: file)
            }

            await self.refreshRegistry.setTask(task, for: file)
        }
    }
    
    /// Retry configuration
    private let maxRetryAttempts: Int
    private let baseRetryDelay: UInt64 // nanoseconds
    private let sleeper: Sleeper
    /// In-memory and disk cache used for URLSession requests.
    private let cache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                 diskCapacity: 50 * 1024 * 1024,
                                 diskPath: "github_cache")
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
        sleeper: @escaping Sleeper = { try await Task.sleep(nanoseconds: $0) }
    ) {
        self.session = session
        self.baseURL = baseURL
        self.maxRetryAttempts = maxRetryAttempts
        self.baseRetryDelay = baseRetryDelay
        self.sleeper = sleeper

        // Создаем директорию для кэша
        let directories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = directories[0].appendingPathComponent("InGermanyCache")

        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("⚠️ Не удалось создать директорию кэша: \(error)")
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
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            scheduleRefresh(file: file)
            return try decodeData(bundleData)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            scheduleRefresh(file: file)
            return try decodeData(cachedData)
        }
        
        // Шаг 3: Network
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        return try await loadFromNetwork(file: file)
    }
    
    /// Loads JSON with detailed source information for tracking
    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, NetworkDataSource) {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            scheduleRefresh(file: file)
            let decoded: T = try decodeData(bundleData)
            return (decoded, .bundle)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            scheduleRefresh(file: file)
            let decoded: T = try decodeData(cachedData)
            return (decoded, .fileCache)
        }
        
        // Шаг 3: Network
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        let decoded: T = try await loadFromNetwork(file: file)
        return (decoded, .network)
    }
    
    // MARK: - Приватные методы загрузки
    
    /// Executes a network request with exponential backoff retry.
    private func performWithRetry<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var lastError: Error?
        
        while attempt < maxRetryAttempts {
            try Task.checkCancellation()
            do {
                return try await operation()
            } catch {
                if error is CancellationError { throw error }
                lastError = error
                attempt += 1
                
                if attempt >= maxRetryAttempts {
                    break
                }
                
                let delay = baseRetryDelay * UInt64(pow(2.0, Double(attempt - 1)))
                try await sleeper(delay)
            }
        }
        
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
        let url = baseURL.appendingPathComponent(file)

        return try await performWithRetry { [self] in
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad

            let (data, response) = try await self.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }

            self.saveToCache(data: data, for: file)
            return try self.decodeData(data)
        }
    }

    private func refreshFromNetwork(file: String) async {
        let url = baseURL.appendingPathComponent(file)

        do {
            try await performWithRetry { [self] in
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

            print("🔄 [NetworkService] Данные обновлены из сети: \(file)")
        } catch {
            print("⚠️ [NetworkService] Не удалось обновить данные из сети после retry: \(error.localizedDescription)")
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
            print("⚠️ [NetworkService] Ошибка сохранения в файловый кэш: \(error)")
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
        // Cancel any in-flight refresh tasks
        Task { await refreshRegistry.cancelAll() }
    
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("🗑️ [NetworkService] Файловый кэш очищен")
        } catch {
            print("⚠️ [NetworkService] Не удалось очистить кэш: \(error)")
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
