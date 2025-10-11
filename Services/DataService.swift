//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

/// Singleton responsible for loading and caching data (articles, categories, locations) with offline-first strategy.
/// Uses unified caching strategy: Memory Cache → NetworkService (Bundle → File Cache → Network)
actor DataService {
    /// Provides a globally shared instance of DataService.
    static let shared = DataService()

    private let networkService = NetworkService.shared
    private let cacheManager = CacheManager.shared

    // 🔄 Backward-compatible in-memory caches
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    private var lastDataSource: [String: String] = [:]

    // 🔔 Streams for non-blocking UI updates
    private var articleContinuations: [AsyncStream<[Article]>.Continuation] = []
    private var categoryContinuations: [AsyncStream<[Category]>.Continuation] = []
    private var locationContinuations: [AsyncStream<[Location]>.Continuation] = []

    // 🔑 Cache keys
    private enum CacheKeys {
        static let articles = "articles"
        static let categories = "categories"
        static let locations = "locations"
    }

    private init() {}

    // MARK: - Fast cache access (non-blocking)

    /// Returns current cached articles or empty array immediately (no I/O).
    func getCachedArticles() -> [Article] {
        articlesCache ?? []
    }

    /// Returns current cached categories or empty array immediately (no I/O).
    func getCachedCategories() -> [Category] {
        categoriesCache ?? []
    }

    /// Returns current cached locations or empty array immediately (no I/O).
    func getCachedLocations() -> [Location] {
        locationsCache ?? []
    }

    // MARK: - Streams (UI can subscribe and update incrementally)

    /// Subscribe to articles updates. Yields current cache immediately, then future updates.
    func articlesStream() -> AsyncStream<[Article]> {
        AsyncStream { continuation in
            // store continuation
            articleContinuations.append(continuation)
            // yield current value immediately
            continuation.yield(articlesCache ?? [])
        }
    }

    /// Subscribe to categories updates.
    func categoriesStream() -> AsyncStream<[Category]> {
        AsyncStream { continuation in
            categoryContinuations.append(continuation)
            continuation.yield(categoriesCache ?? [])
        }
    }

    /// Subscribe to locations updates.
    func locationsStream() -> AsyncStream<[Location]> {
        AsyncStream { continuation in
            locationContinuations.append(continuation)
            continuation.yield(locationsCache ?? [])
        }
    }

    // MARK: - Fire-and-forget preload (does not block UI)

    /// Kicks off background loading of all datasets. UI can render immediately.
    func preloadAll() {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            _ = await self.loadArticles()
            _ = await self.loadCategories()
            _ = await self.loadLocations()
        }
    }

    // MARK: - Unified Offline-First loaders (keep API)

    /// Loads articles with unified offline-first strategy:
    /// Memory Cache → NetworkService (Bundle → File Cache → Network)
    /// - Returns: Array of Article objects.
    func loadArticles() async -> [Article] {
        // Try unified cache first
        if let cached: [Article] = await cacheManager.get(CacheKeys.articles) {
            lastDataSource["articles"] = "memory_cache"
            // keep legacy cache
            articlesCache = cached
            // broadcast
            yieldArticles(cached)

            // Soft refresh in the background (non-blocking for caller)
            Task { [weak self] in
                await self?.refreshArticlesIfNeeded()
            }

            return cached
        }

        // Load via NetworkService (which itself tries Bundle → File Cache → Network)
        do {
            let (articles, source): ([Article], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "articles.json")

            await cacheManager.set(CacheKeys.articles, value: articles)
            articlesCache = articles
            lastDataSource["articles"] = source.rawValue

            // broadcast
            yieldArticles(articles)
            return articles

        } catch {
            // Fallback to direct Bundle load
            let localArticles = await loadLocalArticles()
            if !localArticles.isEmpty {
                await cacheManager.set(CacheKeys.articles, value: localArticles)
                articlesCache = localArticles
                lastDataSource["articles"] = "local_fallback"

                // broadcast
                yieldArticles(localArticles)
                return localArticles
            }

            return []
        }
    }

    /// Loads articles with detailed source tracking
    func loadArticlesWithSource() async -> ([Article], String) {
        let articles = await loadArticles()
        let source = lastDataSource["articles"] ?? "unknown"
        return (articles, source)
    }

    /// Loads categories with unified offline-first strategy
    func loadCategories() async -> [Category] {
        if let cached: [Category] = await cacheManager.get(CacheKeys.categories) {
            lastDataSource["categories"] = "memory_cache"
            categoriesCache = cached
            yieldCategories(cached)

            Task { [weak self] in
                await self?.refreshCategoriesIfNeeded()
            }

            return cached
        }

        do {
            let (categories, source): ([Category], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "categories.json")

            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = source.rawValue

            yieldCategories(categories)
            return categories

        } catch {
            let localCategories = await loadLocalCategories()
            if !localCategories.isEmpty {
                await cacheManager.set(CacheKeys.categories, value: localCategories)
                categoriesCache = localCategories
                lastDataSource["categories"] = "local_fallback"

                yieldCategories(localCategories)
                return localCategories
            }

            return []
        }
    }

    /// Loads locations with unified offline-first strategy
    func loadLocations() async -> [Location] {
        if let cached: [Location] = await cacheManager.get(CacheKeys.locations) {
            lastDataSource["locations"] = "memory_cache"
            locationsCache = cached
            yieldLocations(cached)

            Task { [weak self] in
                await self?.refreshLocationsIfNeeded()
            }

            return cached
        }

        do {
            let (locations, source): ([Location], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "locations.json")

            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = source.rawValue

            yieldLocations(locations)
            return locations

        } catch {
            let localLocations = await loadLocalLocations()
            if !localLocations.isEmpty {
                await cacheManager.set(CacheKeys.locations, value: localLocations)
                locationsCache = localLocations
                lastDataSource["locations"] = "local_fallback"

                yieldLocations(localLocations)
                return localLocations
            }

            return []
        }
    }

    // MARK: - Smart refresh (kept logic)

    private func refreshArticlesIfNeeded() async {
        do {
            let (articles, source): ([Article], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "articles.json")

            if source == .network {
                await cacheManager.set(CacheKeys.articles, value: articles)
                articlesCache = articles
                lastDataSource["articles"] = source.rawValue
                yieldArticles(articles)
            }
        } catch {
            // ignore refresh errors
        }
    }

    private func refreshCategoriesIfNeeded() async {
        do {
            let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = "network"
            yieldCategories(categories)
        } catch {
            // ignore refresh errors
        }
    }

    private func refreshLocationsIfNeeded() async {
        do {
            let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = "network"
            yieldLocations(locations)
        } catch {
            // ignore refresh errors
        }
    }

    // MARK: - Local fallbacks

    private func loadLocalArticles() async -> [Article] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let file = Bundle.main.url(forResource: "articles", withExtension: "json") else {
                    continuation.resume(returning: [])
                    return
                }
                do {
                    let data = try Data(contentsOf: file)
                    let decoded = try JSONDecoder().decode([Article].self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func loadLocalCategories() async -> [Category] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let file = Bundle.main.url(forResource: "categories", withExtension: "json") else {
                    continuation.resume(returning: [])
                    return
                }
                do {
                    let data = try Data(contentsOf: file)
                    let decoded = try JSONDecoder().decode([Category].self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func loadLocalLocations() async -> [Location] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let file = Bundle.main.url(forResource: "locations", withExtension: "json") else {
                    continuation.resume(returning: [])
                    return
                }
                do {
                    let data = try Data(contentsOf: file)
                    let decoded = try JSONDecoder().decode([Location].self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    // MARK: - Broadcasting helpers

    private func yieldArticles(_ value: [Article]) {
        for c in articleContinuations { c.yield(value) }
    }

    private func yieldCategories(_ value: [Category]) {
        for c in categoryContinuations { c.yield(value) }
    }

    private func yieldLocations(_ value: [Location]) {
        for c in locationContinuations { c.yield(value) }
    }

    // MARK: - Cache control

    /// Clears all cached data and resets the last data source information.
    func clearCache() {
        Task { await cacheManager.clear() }
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        networkService.clearCache()
        lastDataSource.removeAll()
        // Do not close streams; just yield empty to subscribers
        yieldArticles([])
        yieldCategories([])
        yieldLocations([])
    }

    /// Clears only articles cache while preserving categories and locations
    func clearArticlesCache() async {
        await cacheManager.clear(CacheKeys.articles)
        articlesCache = nil
        lastDataSource["articles"] = nil
        yieldArticles([])
    }

    /// Clears only categories cache while preserving articles and locations
    func clearCategoriesCache() async {
        await cacheManager.clear(CacheKeys.categories)
        categoriesCache = nil
        lastDataSource["categories"] = nil
        yieldCategories([])
    }

    /// Clears only locations cache while preserving articles and categories
    func clearLocationsCache() async {
        await cacheManager.clear(CacheKeys.locations)
        locationsCache = nil
        lastDataSource["locations"] = nil
        yieldLocations([])
    }

    /// Forces a refresh by clearing caches and reloading all data.
    func refreshData() async {
        clearCache()
        _ = await loadArticles()
        _ = await loadCategories()
        _ = await loadLocations()
    }

    // MARK: - UI API

    /// Returns a dictionary containing the last used data source information for articles, categories, and locations.
    /// - Returns: Dictionary with keys as data types and values as the last data source string.
    func getLastDataSource() async -> [String: String] {
        lastDataSource
    }
}
