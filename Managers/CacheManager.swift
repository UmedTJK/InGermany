//
//  CacheManager.swift
//  InGermany
//
//  Created by SUM TJK on 08.10.25.
//
// CacheManager.swift
// Managers/CacheManager.swift
import Foundation

/// Unified cache manager for memory caching with TTL support
actor CacheManager {
    /// Shared singleton instance
    static let shared = CacheManager()
    
    private var memoryCache: [String: Any] = [:]
    private let defaultCacheLifetime: TimeInterval = 15 * 60 // 15 минут
    
    private init() {}
    
    /// Retrieves cached value for key with TTL check
    func get<T>(_ key: String, lifetime: TimeInterval? = nil) -> T? {
        guard let cached = memoryCache[key] as? CacheEntry<T> else { return nil }
        
        let cacheLifetime = lifetime ?? defaultCacheLifetime
        if Date().timeIntervalSince(cached.timestamp) > cacheLifetime {
            memoryCache.removeValue(forKey: key)
            return nil
        }
        
        return cached.value
    }
    
    /// Stores value in cache with current timestamp
    func set<T>(_ key: String, value: T) {
        memoryCache[key] = CacheEntry(value: value, timestamp: Date())
    }
    
    /// Clears specific cache entry or all cache
    func clear(_ key: String? = nil) {
        if let key = key {
            memoryCache.removeValue(forKey: key)
        } else {
            memoryCache.removeAll()
        }
    }
    
    /// Checks if cache entry exists and is valid
    func hasValidCache(_ key: String, lifetime: TimeInterval? = nil) -> Bool {
        return get(key, lifetime: lifetime) != nil
    }
}

private struct CacheEntry<T> {
    let value: T
    let timestamp: Date
}
