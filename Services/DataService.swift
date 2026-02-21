//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

actor DataService: DataServiceProtocol {

    // MARK: - Dependencies (DI-only; no singletons)
    private let networkService: NetworkServiceProtocol
    private let cacheManager: CacheServiceProtocol

    // MARK: - Memory caches
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    // MARK: - Metadata
    private var lastDataSource: [String: String] = [:]

    // MARK: - In-flight refresh dedup (one per resource)
    private enum RefreshKind: Hashable {
        case articles, categories, locations
    }
    
    private var inFlightRefresh: [RefreshKind: Task<Void, Never>] = [:]
    
    private func scheduleRefresh(
        _ kind: RefreshKind,
        _ operation: @escaping @Sendable (DataService) async -> Void
    ) {
        // Dedup: if there is an in-flight refresh for this kind, don't start another.
        guard inFlightRefresh[kind] == nil else { return }
        
        inFlightRefresh[kind] = Task { [weak self] in
            guard let self else { return }
            defer { Task { await self.clearInFlight(kind) } }
            await operation(self)
        }
    }
    
    private func clearInFlight(_ kind: RefreshKind) {
        inFlightRefresh[kind] = nil
    }

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
        let start = Date()
        
        scheduleRefresh(.articles) { service in
            await service.refreshArticlesIfNeeded()
        }
        scheduleRefresh(.categories) { service in
            await service.refreshCategoriesIfNeeded()
        }
        scheduleRefresh(.locations) { service in
            await service.refreshLocationsIfNeeded()
        }
        
        print("⏱ [DataService] preloadAll refresh scheduled in \(Date().timeIntervalSince(start)) sec")
    }

    // MARK: - Unified loaders

    func loadArticles() async -> [Article] {
        let start = Date()
        print("⏱ [DataService] loadArticles started at \(start)")

        // ✅ MEMORY cache
        if let cached = articlesCache {
            lastDataSource["articles"] = "memory_cache"
            print("⏱ [DataService] loadArticles returned from MEMORY in \(Date().timeIntervalSince(start)) sec")

            // background refresh (dedup, non-blocking)
            scheduleRefresh(.articles) { service in
                await service.refreshArticlesIfNeeded()
            }
            return cached
        }

        // ✅ TTL cache (CacheService)
        if let cached: [Article] = await cacheManager.get(CacheKeys.articles, lifetime: nil) {
            articlesCache = cached
            lastDataSource["articles"] = "memory_cache"
            yieldArticles(cached)
            print("⏱ [DataService] loadArticles returned from DISK/TTL cache in \(Date().timeIntervalSince(start)) sec")

            scheduleRefresh(.articles) { service in
                await service.refreshArticlesIfNeeded()
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
            let (articles, source): ([Article], NetworkDataSource) = try await networkService.loadJSONWithSource(from: "articles.json")

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

            scheduleRefresh(.categories) { service in
                let networkStart = Date()
                await service.refreshCategoriesIfNeeded()
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

            scheduleRefresh(.categories) { service in
                let networkStart = Date()
                await service.refreshCategoriesIfNeeded()
                print("⏱ [DataService] refreshCategoriesIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return local
        }

        do {
            let networkStart = Date()
            let (categories, source): ([Category], NetworkDataSource) = try await networkService.loadJSONWithSource(from: "categories.json")
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

            scheduleRefresh(.locations) { service in
                let networkStart = Date()
                await service.refreshLocationsIfNeeded()
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

            scheduleRefresh(.locations) { service in
                let networkStart = Date()
                await service.refreshLocationsIfNeeded()
                print("⏱ [DataService] refreshLocationsIfNeeded finished in \(Date().timeIntervalSince(networkStart)) sec")
            }
            return local
        }

        do {
            let networkStart = Date()
            let (locations, source): ([Location], NetworkDataSource) = try await networkService.loadJSONWithSource(from: "locations.json")
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
            let (articles, source): ([Article], NetworkDataSource) = try await networkService.loadJSONWithSource(from: "articles.json")
            if source == .network {
                await cacheManager.set(CacheKeys.articles, value: articles)
                articlesCache = articles
                lastDataSource["articles"] = source.rawValue
                yieldArticles(articles)
            }
        } catch {
            print("⚠️ [DataService] refreshArticlesIfNeeded failed: \(error)")
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
            print("⚠️ [DataService] refreshCategoriesIfNeeded failed: \(error)")
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
            print("⚠️ [DataService] refreshLocationsIfNeeded failed: \(error)")
        }
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

        // Cancel any in-flight refresh tasks
        for (_, task) in inFlightRefresh { task.cancel() }
        inFlightRefresh.removeAll()

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
