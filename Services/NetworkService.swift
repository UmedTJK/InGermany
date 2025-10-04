//
//  NetworkService.swift
//  InGermany
//
//  Created by SUM TJK on 20.09.25.
//

//
//  NetworkService.swift
//  InGermany
//
//  Created by Umed Sabzaev on 20.09.25.
//

import Foundation

/// A singleton service responsible for loading JSON data from the network, cache, or local bundle.
/// Provides async and sync methods with fallback mechanisms and simple caching.
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
    
    /// Loads and decodes a JSON file into a specified Decodable type.
    /// The method tries network first, then cache, then local bundle.
    /// - Parameter file: The filename of the JSON resource.
    /// - Returns: A decoded object of type `T`.
    /// - Throws: An error if the data cannot be loaded or decoded.
    func loadJSON<T: Decodable>(from file: String) async throws -> T {
        let url = URL(string: baseURL + file)!
        
        // Пытаемся загрузить из сети
        if let data = try await loadFromNetwork(url: url) {
            // Сохраняем в кэш
            saveToCache(data: data, for: file)
            return try decodeData(data)
        }
        
        // Пытаемся загрузить из кэша
        if let cachedData = loadFromCache(for: file) {
            return try decodeData(cachedData)
        }
        
        // Fallback на локальные файлы
        return try loadLocalFile(file)
    }
    
    /// Attempts to fetch data from the network.
    /// - Parameter url: The remote URL.
    /// - Returns: Data if the request succeeds with status 200, otherwise nil.
    private func loadFromNetwork(url: URL) async throws -> Data? {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }
        
        return data
    }
    
    /// Attempts to read cached data from disk.
    /// - Parameter file: The filename of the cached JSON.
    /// - Returns: Data if found, otherwise nil.
    private func loadFromCache(for file: String) -> Data? {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        return try? Data(contentsOf: cacheFile)
    }
    
    /// Saves given data to the local cache directory.
    /// - Parameters:
    ///   - data: Data to save.
    ///   - file: Filename used as cache key.
    private func saveToCache(data: Data, for file: String) {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        try? data.write(to: cacheFile)
    }
    
    /// Loads and decodes a JSON file from the app bundle.
    /// - Parameter filename: The name of the file in the bundle.
    /// - Returns: A decoded object of type `T`.
    /// - Throws: An error if the file cannot be found or decoded.
    private func loadLocalFile<T: Decodable>(_ filename: String) throws -> T {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Файл \(filename) не найден"])
        }
        
        let data = try Data(contentsOf: file)
        return try decodeData(data)
    }
    
    /// Decodes raw Data into a Decodable object.
    /// - Parameter data: JSON data.
    /// - Returns: A decoded object of type `T`.
    /// - Throws: An error if decoding fails.
    private func decodeData<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
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
        } catch {
            print("⚠️ Не удалось очистить кэш: \(error)")
        }
    }
}
