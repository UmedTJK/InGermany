//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

actor DataService: DataServiceProtocol {

    // MARK: - Temporary singleton bridge (keep during DI migration)
    static let shared = DataService(
        networkService: NetworkService.shared,
        cacheManager: CacheService()
    )

    // MARK: - Dependencies (DI)
    private let networkService: NetworkServiceProtocol
    private let cacheManager: CacheServiceProtocol

    // MARK: - Memory caches
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    // MARK: - Metadata
    private var lastDataSource: [String: String] = [:]

    // MARK: - Streams
    private var articleContinuations: [AsyncStream<[Article]>.Continuation] = []
    private var categoryContinuations: [AsyncStream<[Category]>.Continuation] = []
    private var locationContinuations: [AsyncStream<[Location]>.Continuation] = []

    private enum CacheKeys {
        static let articles = "articles"
        static let categories = "categories"
        static let locations = "locations"
    }

    // MARK: - Init
    init(
        networkService: NetworkServiceProtocol,
        cacheManager: CacheServiceProtocol
    ) {
        self.networkService = networkService
        self.cacheManager = cacheManager
    }

    // MARK: - Fast cache access
    func getCachedArticles() -> [Article] { articlesCache ?? [] }
    func getCachedCategories() -> [Category] { categoriesCache ?? [] }
    func getCachedLocations() -> [Location] { locationsCache ?? [] }

    // MARK: - Streams
    func articlesStream() -> AsyncStream<[Article]> {
        AsyncStream { continuation in
            articleContinuations.append(continuation)
            continuation.yield(articlesCache ?? [])
        }
    }

    func categoriesStream() -> AsyncStream<[Category]> {
        AsyncStream { continuation in
            categoryContinuations.append(continuation)
            continuation.yield(categoriesCache ?? [])
        }
    }

    func locationsStream() -> AsyncStream<[Location]> {
        AsyncStream { continuation in
            locationContinuations.append(continuation)
            continuation.yield(locationsCache ?? [])
        }
    }

    // MARK: - Fire-and-forget preload
    func preloadAll() {
        Task.detached { [weak self] in
            guard let self else { return }
            let start = Date()
            await self.refreshArticlesIfNeeded()
            await self.refreshCategoriesIfNeeded()
            await self.refreshLocationsIfNeeded()
            print("⏱ [DataService] preloadAll refresh finished in \(Date().timeIntervalSince(start)) sec")
        }
    }

    // MARK: - Unified loaders

    func loadArticles() async -> [Article] {
        let start = Date()
        print("⏱ [DataService] loadArticles started at \(start)")

        // ✅ MEMORY cache
        if let cached = articlesCache {
            lastDataSource["articles"] = "memory_cache"
            print("⏱ [DataService] loadArticles returned from MEMORY in \(Date().timeIntervalSince(start)) sec")

            // background refresh without blocking UI
            Task.detached { [weak self] in
                await self?.refreshArticlesIfNeeded()
            }
            return cached
        }

        // ✅ TTL cache (CacheService)
        if let cached: [Article] = await cacheManager.get(CacheKeys.articles, lifetime: nil) {
            articlesCache = cached
            lastDataSource["articles"] = "memory_cache"
            yieldArticles(cached)
            print("⏱ [DataService] loadArticles returned from DISK/TTL cache in \(Date().timeIntervalSince(start)) sec")

            Task.detached { [weak self] in
                await self?.refreshArticlesIfNeeded()
            }
            return cached
        }

        // ⚡ parallel: bundle load + network prep
        async let localTask = loadLocalArticles()
        async let networkPrepTask: Void = prepareNetworkRefresh()

        let local = await localTask
        await networkPrepTask

        if !local.isEmpty {
            await cacheManager.set(CacheKeys.articles, value: local)
            articlesCache = local
            lastDataSource["articles"] = "local_bundle"
            yieldArticles(local)
            print("⏱ [DataService] loadArticles returned from BUNDLE in \(Date().timeIntervalSince(start)) sec")
            return local
        }

        // Network only if local not available
        return await loadArticlesFromNetwork()
    }

    // no-op now; keep hook for future
    private func prepareNetworkRefresh() async {}

    private func loadArticlesFromNetwork() async -> [Article] {
        do {
            let (articles, source): ([Article], NetworkService.DataSource) = try await networkService.loadJSONWithSource(from: "articles.json")

            await cacheManager.set(CacheKeys.articles, value: articles)
            articlesCache = articles
            lastDataSource["articles"] = source.rawValue
            yieldArticles(articles)
            return articles
        } catch {
            print("⚠️ [DataService] loadArticles network failed: \(error)")
            return []
        }
    }

    func loadArticlesWithSource() async -> ([Article], String) {
        let articles = await loadArticles()
        let source = lastDataSource["articles"] ?? "unknown"
        return (articles, source)
    }

    func loadCategories() async -> [Category] {
        let start = Date()
        print("⏱ [DataService] loadCategories started at \(start)")

        if let cached: [Category] = await cacheManager.get(CacheKeys.categories, lifetime: nil) {
            lastDataSource["categories"] = "memory_cache"
            categoriesCache = cached
            yieldCategories(cached)
            print("⏱ [DataService] loadCategories returned from TTL cache in \(Date().timeIntervalSince(start)) sec")

            Task.detached { [weak self] in
                guard let self else { return }
                let networkStart = Date()
                await self.refreshCategoriesIfNeeded()
                print("⏱ [DataService] refreshCategoriesIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return cached
        }

        let local = await loadLocalCategories()
        if !local.isEmpty {
            await cacheManager.set(CacheKeys.categories, value: local)
            categoriesCache = local
            lastDataSource["categories"] = "local_bundle"
            yieldCategories(local)
            print("⏱ [DataService] loadCategories returned from bundle in \(Date().timeIntervalSince(start)) sec")

            Task.detached { [weak self] in
                guard let self else { return }
                let networkStart = Date()
                await self.refreshCategoriesIfNeeded()
                print("⏱ [DataService] refreshCategoriesIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return local
        }

        do {
            let networkStart = Date()
            let (categories, source): ([Category], NetworkService.DataSource) = try await networkService.loadJSONWithSource(from: "categories.json")
            print("⏱ [DataService] loadCategories network finished in \(Date().timeIntervalSince(networkStart)) sec")

            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = source.rawValue
            yieldCategories(categories)
            return categories
        } catch {
            print("⚠️ [DataService] loadCategories network failed after \(Date().timeIntervalSince(start)) sec: \(error)")
            return []
        }
    }

    func loadLocations() async -> [Location] {
        let start = Date()
        print("⏱ [DataService] loadLocations started at \(start)")

        if let cached: [Location] = await cacheManager.get(CacheKeys.locations, lifetime: nil) {
            lastDataSource["locations"] = "memory_cache"
            locationsCache = cached
            yieldLocations(cached)
            print("⏱ [DataService] loadLocations returned from TTL cache in \(Date().timeIntervalSince(start)) sec")

            Task.detached { [weak self] in
                guard let self else { return }
                let networkStart = Date()
                await self.refreshLocationsIfNeeded()
                print("⏱ [DataService] refreshLocationsIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return cached
        }

        let local = await loadLocalLocations()
        if !local.isEmpty {
            await cacheManager.set(CacheKeys.locations, value: local)
            locationsCache = local
            lastDataSource["locations"] = "local_bundle"
            yieldLocations(local)
            print("⏱ [DataService] loadLocations returned from bundle in \(Date().timeIntervalSince(start)) sec")

            Task.detached { [weak self] in
                guard let self else { return }
                let networkStart = Date()
                await self.refreshLocationsIfNeeded()
                print("⏱ [DataService] refreshLocationsIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return local
        }

        do {
            let networkStart = Date()
            let (locations, source): ([Location], NetworkService.DataSource) = try await networkService.loadJSONWithSource(from: "locations.json")
            print("⏱ [DataService] loadLocations network finished in \(Date().timeIntervalSince(networkStart)) sec")

            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = source.rawValue
            yieldLocations(locations)
            return locations
        } catch {
            print("⚠️ [DataService] loadLocations network failed after \(Date().timeIntervalSince(start)) sec: \(error)")
            return []
        }
    }

    // MARK: - Refresh helpers (background)
    private func refreshArticlesIfNeeded() async {
        do {
            let (articles, source): ([Article], NetworkService.DataSource) = try await networkService.loadJSONWithSource(from: "articles.json")
            if source == .network {
                await cacheManager.set(CacheKeys.articles, value: articles)
                articlesCache = articles
                lastDataSource["articles"] = source.rawValue
                yieldArticles(articles)
            }
        } catch {}
    }

    private func refreshCategoriesIfNeeded() async {
        do {
            let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = "network"
            yieldCategories(categories)
        } catch {}
    }

    private func refreshLocationsIfNeeded() async {
        do {
            let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = "network"
            yieldLocations(locations)
        } catch {}
    }

    // MARK: - Local fallbacks
    private func loadLocalArticles() async -> [Article] { await loadLocal("articles.json") }
    private func loadLocalCategories() async -> [Category] { await loadLocal("categories.json") }
    private func loadLocalLocations() async -> [Location] { await loadLocal("locations.json") }

    private func loadLocal<T: Decodable>(_ filename: String) async -> [T] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let name = filename.replacingOccurrences(of: ".json", with: "")
                guard let file = Bundle.main.url(forResource: name, withExtension: "json") else {
                    continuation.resume(returning: []); return
                }
                do {
                    let data = try Data(contentsOf: file)
                    let decoded = try JSONDecoder().decode([T].self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    // MARK: - Broadcasting helpers
    private func yieldArticles(_ value: [Article]) { for c in articleContinuations { c.yield(value) } }
    private func yieldCategories(_ value: [Category]) { for c in categoryContinuations { c.yield(value) } }
    private func yieldLocations(_ value: [Location]) { for c in locationContinuations { c.yield(value) } }

    // MARK: - Cache control (Protocol API)

    func clearCache() async {
        await cacheManager.clear(nil)
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil

        networkService.clearCache()
        lastDataSource.removeAll()

        yieldArticles([])
        yieldCategories([])
        yieldLocations([])
    }

    func clearArticlesCache() async {
        await cacheManager.clear(CacheKeys.articles)
        articlesCache = nil
        lastDataSource["articles"] = nil
        yieldArticles([])
    }

    // Additional helpers (not in protocol, but useful)
    func clearCategoriesCache() async {
        await cacheManager.clear(CacheKeys.categories)
        categoriesCache = nil
        lastDataSource["categories"] = nil
        yieldCategories([])
    }

    func clearLocationsCache() async {
        await cacheManager.clear(CacheKeys.locations)
        locationsCache = nil
        lastDataSource["locations"] = nil
        yieldLocations([])
    }

    func refreshData() async {
        await clearCache()
        _ = await loadArticles()
        _ = await loadCategories()
        _ = await loadLocations()
    }

    func getLastDataSource() async -> [String: String] {
        lastDataSource
    }
}
