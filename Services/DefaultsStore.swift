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
enum DefaultsStore {
    /// Loads a Codable object from UserDefaults for the given key.
    static func load<T: Codable>(_ key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Saves a Codable object to UserDefaults for the given key.
    static func save<T: Codable>(_ value: T, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
