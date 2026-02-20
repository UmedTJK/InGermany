//
//  NetworkService.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

import Foundation

/// Service responsible for loading JSON data with OFFLINE-FIRST strategy.
/// Uses: Bundle → File Cache → Network (async refresh)
class NetworkService {
    
    /// Base URL pointing to the GitHub raw resources used for fetching JSON files.
    private let baseURL = "https://raw.githubusercontent.com/UmedTJK/InGermany/main/Resources/"
    /// In-memory and disk cache used for URLSession requests.
    private let cache = URLCache(memoryCapacity: 10 * 1024 * 1024,
                                 diskCapacity: 50 * 1024 * 1024,
                                 diskPath: "github_cache")
    /// FileManager instance for file system operations.
    private let fileManager = FileManager.default
    /// Directory where cached JSON files are stored.
    private let cacheDirectory: URL

    /// Custom URLSession with reduced timeouts
    // В NetworkService.swift
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0    // ⬇️ Уменьшаем с 3 до 2 секунд
        config.timeoutIntervalForResource = 2.0   // ⬇️ Уменьшаем с 3 до 2 секунд
        config.waitsForConnectivity = false       // ❌ Не ждем подключения
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    /// Initializes cache directory and session configuration
    init() {
        // Создаем директорию для кэша
        let directories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = directories[0].appendingPathComponent("InGermanyCache")
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("⚠️ Не удалось создать директорию кэша: \(error)")
        }
    }
    
    // MARK: - Основной API
    
    /// Loads and decodes a JSON file into a specified Decodable type with OFFLINE-FIRST strategy.
    /// Strategy: Bundle → File Cache → Network (with async refresh)
    func loadJSON<T: Decodable>(from file: String) async throws -> T {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            Task { await refreshFromNetwork(file: file) }
            return try decodeData(bundleData)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            Task { await refreshFromNetwork(file: file) }
            return try decodeData(cachedData)
        }
        
        // Шаг 3: Network
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        return try await loadFromNetwork(file: file)
    }
    
    /// Loads JSON with detailed source information for tracking
    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, DataSource) {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            Task { await refreshFromNetwork(file: file) }
            let decoded: T = try decodeData(bundleData)
            return (decoded, .bundle)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            Task { await refreshFromNetwork(file: file) }
            let decoded: T = try decodeData(cachedData)
            return (decoded, .fileCache)
        }
        
        // Шаг 3: Network
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        let decoded: T = try await loadFromNetwork(file: file)
        return (decoded, .network)
    }
    
    // MARK: - Приватные методы загрузки
    
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
        let url = URL(string: baseURL + file)!
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        saveToCache(data: data, for: file)
        return try decodeData(data)
    }
    
    private func refreshFromNetwork(file: String) async {
        let url = URL(string: baseURL + file)!
        
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 3.0
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return
            }
            
            saveToCache(data: data, for: file)
            print("🔄 [NetworkService] Данные обновлены из сети: \(file)")
        } catch {
            print("⚠️ [NetworkService] Не удалось обновить данные из сети: \(error.localizedDescription)")
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
