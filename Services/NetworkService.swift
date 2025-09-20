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

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://raw.githubusercontent.com/UmedTJK/InGermany/main/Resources/"
    private let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "github_cache")
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
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
    
    private func loadFromCache(for file: String) -> Data? {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        return try? Data(contentsOf: cacheFile)
    }
    
    private func saveToCache(data: Data, for file: String) {
        let cacheFile = cacheDirectory.appendingPathComponent(file)
        try? data.write(to: cacheFile)
    }
    
    private func loadLocalFile<T: Decodable>(_ filename: String) throws -> T {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Файл \(filename) не найден"])
        }
        
        let data = try Data(contentsOf: file)
        return try decodeData(data)
    }
    
    private func decodeData<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // Метод для синхронной загрузки (для обратной совместимости)
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
    
    // Очистка кэша
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
