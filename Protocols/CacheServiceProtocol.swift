//
//  CacheServiceProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 20.02.26.
//
//

import Foundation

/// Actor-friendly cache protocol (TTL in-memory cache).
protocol CacheServiceProtocol {
    func get<T>(_ key: String, lifetime: TimeInterval?) async -> T?
    func set<T>(_ key: String, value: T) async
    func clear(_ key: String?) async
    func hasValidCache(_ key: String, lifetime: TimeInterval?) async -> Bool
}
