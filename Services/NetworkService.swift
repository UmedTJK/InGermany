//
//  NetworkService.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

import Foundation

/// A singleton service responsible for loading JSON data with OFFLINE-FIRST strategy.
/// Uses: Bundle → File Cache → Network (async update)
class NetworkService {
    /// Shared singleton instance of `NetworkService`.
    static let shared = NetworkService()
    
    /// Base URL pointing to the GitHub raw resources used for fetching JSON files.
    private let baseURL = "https://raw.githubusercontent.com/UmedTJK/InGermany/main/Resources/"
    /// In-memory and disk cache used for URLSession requests.
    private let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "github_cache")
    /// FileManager instance for file system operations.
    private let fileManager = FileManager.default
    /// Directory where cached JSON files are stored.
    private let cacheDirectory: URL
    
    /// Private initializer. Sets up the cache directory on first use.
    private init() {
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
    /// - Parameter file: The filename of the JSON resource.
    /// - Returns: A decoded object of type `T`.
    /// - Throws: An error if the data cannot be loaded or decoded.
    func loadJSON<T: Decodable>(from file: String) async throws -> T {
        // 🔄 ИЗМЕНЕНО: Теперь настоящий offline-first
        
        // Шаг 1: Пытаемся загрузить из Bundle (самый быстрый, всегда доступный)
        if let bundleData = loadFromBundle(file: file) {
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            
            // Асинхронно обновляем из сети если доступно
            Task {
                await refreshFromNetwork(file: file)
            }
            
            return try decodeData(bundleData)
        }
        
        // Шаг 2: Пытаемся загрузить из файлового кэша
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            
            // Асинхронно обновляем из сети если доступно
            Task {
                await refreshFromNetwork(file: file)
            }
            
            return try decodeData(cachedData)
        }
        
        // Шаг 3: Загружаем из сети (только если предыдущие шаги не сработали)
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        return try await loadFromNetwork(file: file)
    }
    
    /// Loads JSON with detailed source information for tracking
    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, DataSource) {
        // Шаг 1: Bundle
        if let bundleData = loadFromBundle(file: file) {
            print("📦 [NetworkService] Загружено из Bundle: \(file)")
            
            Task {
                await refreshFromNetwork(file: file)
            }
            
            // 🔧 ИСПРАВЛЕНО: Явно указываем тип при декодировании
            let decoded: T = try decodeData(bundleData)
            return (decoded, .bundle)
        }
        
        // Шаг 2: File Cache
        if let cachedData = loadFromCache(for: file) {
            print("📂 [NetworkService] Загружено из файлового кэша: \(file)")
            
            Task {
                await refreshFromNetwork(file: file)
            }
            
            // 🔧 ИСПРАВЛЕНО: Явно указываем тип при декодировании
            let decoded: T = try decodeData(cachedData)
            return (decoded, .fileCache)
        }
        
        // Шаг 3: Network
        print("🌐 [NetworkService] Загружаем из сети: \(file)")
        let decoded: T = try await loadFromNetwork(file: file)
        return (decoded, .network)
    }
    
    // MARK: - Приватные методы загрузки
    
    /// Загружает данные из Bundle (самый приоритетный источник)
    private func loadFromBundle(file: String) -> Data? {
        guard let bundleURL = Bundle.main.url(forResource: file, withExtension: nil) else {
            return nil
        }
        return try? Data(contentsOf: bundleURL)
    }
    
    /// Загружает данные из файлового кэша
    private func loadFromCache(for file: String) -> Data? {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        return try? Data(contentsOf: cacheFile)
    }
    
    /// Загружает данные из сети (последний резерв)
    private func loadFromNetwork<T: Decodable>(file: String) async throws -> T {
        let url = URL(string: baseURL + file)!
        
        var request = URLRequest(url: url)
        // 🔄 ИЗМЕНЕНО: Было .reloadIgnoringLocalCacheData
        request.cachePolicy = .returnCacheDataElseLoad // Теперь используем кэш
        request.timeoutInterval = 10.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // Сохраняем в файловый кэш для будущего использования
        saveToCache(data: data, for: file)
        
        return try decodeData(data)
    }
    
    /// Асинхронно обновляет данные из сети (для уже загруженных локальных данных)
    private func refreshFromNetwork(file: String) async {
        let url = URL(string: baseURL + file)!
        
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData // Для обновления игнорируем кэш
            request.timeoutInterval = 8.0 // Более короткий таймаут для обновлений
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return
            }
            
            // Сохраняем обновленные данные
            saveToCache(data: data, for: file)
            print("🔄 [NetworkService] Данные обновлены из сети: \(file)")
            
        } catch {
            print("⚠️ [NetworkService] Не удалось обновить данные из сети: \(error.localizedDescription)")
            // Тихий fail - не прерываем основной поток
        }
    }
    
    // MARK: - Вспомогательные методы
    
    /// Сохраняет данные в файловый кэш
    private func saveToCache(data: Data, for file: String) {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        
        // Создаем директорию если нужно
        let directory = cacheFile.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        do {
            try data.write(to: cacheFile)
        } catch {
            print("⚠️ [NetworkService] Ошибка сохранения в файловый кэш: \(error)")
        }
    }
    
    /// Декодирует данные в указанный тип
    private func decodeData<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Legacy API (сохраняем для обратной совместимости)
    
    /// Legacy synchronous-style JSON loader wrapping the async method.
    /// - Parameters:
    ///   - file: The filename of the JSON resource.
    ///   - completion: Completion handler returning result with decoded object or error.
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
    
    /// Clears all cached JSON files from the cache directory.
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
    /// Источники данных для отслеживания
    enum DataSource: String {
        case bundle = "bundle"
        case fileCache = "file_cache"
        case network = "network"
    }
    
    /// Ошибки сети
    enum NetworkError: Error {
        case invalidResponse
        case networkUnavailable
    }
}
