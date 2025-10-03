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

enum DefaultsStorage {
    static func load<T: Codable>(_ key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func save<T: Codable>(_ value: T, for key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
