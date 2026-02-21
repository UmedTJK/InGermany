//
//  DefaultsStorage.swift
//  InGermany
//
//  Created by SUM TJK on 27.09.25.
//

//
//  DefaultsStorage.swift
//  InGermany
//

import Foundation

/// Provides helper methods for saving and loading Codable data to UserDefaults.
/// Async variants offload JSON encode/decode to background priority using structured concurrency.
enum DefaultsStore {
    /// Loads a Codable object from UserDefaults for the given key.
    static func load<T: Codable>(_ key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    /// Asynchronously loads a Codable object from UserDefaults on a background priority.
    static func loadAsync<T: Codable>(_ key: String, as type: T.Type) async throws -> T? {
        try await Task(priority: .utility) {
            guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
            return try JSONDecoder().decode(T.self, from: data)
        }.value
    }

    /// Saves a Codable object to UserDefaults for the given key.
    static func save<T: Codable>(_ value: T, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    /// Asynchronously saves a Codable object to UserDefaults on a background priority.
    static func saveAsync<T: Codable>(_ value: T, for key: String) async throws {
        let data = try await Task(priority: .utility) {
            try JSONEncoder().encode(value)
        }.value

        // UserDefaults write itself is lightweight; keep it outside heavy encoding
        UserDefaults.standard.set(data, forKey: key)
    }
    
    /// 🔧 ДОБАВИТЬ ЭТОТ МЕТОД:
    /// Removes data from UserDefaults for the given key.
    static func remove(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
