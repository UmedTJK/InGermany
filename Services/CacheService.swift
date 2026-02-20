//
//  CacheService.swift
//  InGermany
//
//  Created by SUM TJK on 08.10.25.
//

import Foundation

/// Unified in-memory cache with TTL.
/// Note: This is an in-memory TTL cache only.
actor CacheService: CacheServiceProtocol {


    // MARK: - Storage
    private var memoryCache: [String: Any] = [:]
    private let defaultCacheLifetime: TimeInterval = 15 * 60 // 15 minutes

    init() {}

    // MARK: - CacheServiceProtocol

    func get<T>(_ key: String, lifetime: TimeInterval? = nil) async -> T? {
        guard let cached = memoryCache[key] as? CacheEntry<T> else { return nil }

        let cacheLifetime = lifetime ?? defaultCacheLifetime
        if Date().timeIntervalSince(cached.timestamp) > cacheLifetime {
            memoryCache.removeValue(forKey: key)
            return nil
        }

        return cached.value
    }

    func set<T>(_ key: String, value: T) async {
        memoryCache[key] = CacheEntry(value: value, timestamp: Date())
    }

    func clear(_ key: String? = nil) async {
        if let key = key {
            memoryCache.removeValue(forKey: key)
        } else {
            memoryCache.removeAll()
        }
    }

    func hasValidCache(_ key: String, lifetime: TimeInterval? = nil) async -> Bool {
        return await get(key, lifetime: lifetime) as Any? != nil
    }
}

private struct CacheEntry<T> {
    let value: T
    let timestamp: Date
}
