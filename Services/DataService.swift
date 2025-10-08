//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

/// Singleton responsible for loading and caching data (articles, categories, locations) with offline-first strategy.
actor DataService {
    /// Provides a globally shared instance of DataService.
    static let shared = DataService()

    private let networkService = NetworkService.shared
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    private var lastDataSource: [String: String] = [:]

    private init() {}

    // MARK: - Асинхронные методы (Offline-First)

    /// Loads articles with offline-first strategy: returns cached articles if available,
    /// otherwise loads from local JSON, then updates from network asynchronously.
    /// - Returns: Array of Article objects.
    func loadArticles() async -> [Article] {
        if let cached = articlesCache {
            lastDataSource["articles"] = "memory_cache"
            print("📦 [DataService] Articles из памяти (cache)")
            return cached
        }

        let localArticles = await loadLocalArticles()
        if !localArticles.isEmpty {
            articlesCache = localArticles
            lastDataSource["articles"] = "local"
            print("📂 [DataService] Articles из локального JSON")
            print("🔎 Preview первых 3 статей:", Array(localArticles.prefix(3)))
        }

        // 🔄 УЛУЧШЕНО: Теперь NetworkService сам реализует offline-first,
        // поэтому мы можем упростить логику обновления
        Task {
            do {
                let (articles, source): ([Article], NetworkService.DataSource) = try await networkService.loadJSONWithSource(from: "articles.json")
                self.articlesCache = articles
                self.lastDataSource["articles"] = source.rawValue
                print("🌐 [DataService] Articles обновлены из сети (\(source))")
            } catch {
                print("⚠️ [DataService] Ошибка обновления Articles из сети: \(error)")
                // ✅ ЛУЧШЕ: Не перезаписываем кэш, просто логируем ошибку
                // Кэш остается неизменным (уже есть локальные данные)
            }
        }

        return articlesCache ?? []
    }

    // 🔄 ДОБАВЛЕНО: Новый метод для лучшего отслеживания источников
    func loadArticlesWithSource() async -> ([Article], String) {
        let articles = await loadArticles()
        let source = lastDataSource["articles"] ?? "unknown"
        return (articles, source)
    }

    // 🔄 ОСТАВЛЯЕМ существующие методы loadCategories(), loadLocations() без изменений
    // Они уже правильно используют offline-first стратегию

    /// Loads categories with offline-first strategy...
    func loadCategories() async -> [Category] {
        // ... существующая реализация без изменений
        if let cached = categoriesCache {
            lastDataSource["categories"] = "memory_cache"
            print("📦 [DataService] Categories из памяти (cache)")
            return cached
        }

        let local = await loadLocalCategories()
        if !local.isEmpty {
            categoriesCache = local
            lastDataSource["categories"] = "local"
            print("📂 [DataService] Categories из локального JSON")
        }

        Task {
            do {
                let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
                self.categoriesCache = categories
                self.lastDataSource["categories"] = "network"
                print("🌐 [DataService] Categories обновлены из сети")
            } catch {
                print("⚠️ [DataService] Ошибка загрузки Categories из сети: \(error)")
            }
        }

        return categoriesCache ?? []
    }

    /// Loads locations with offline-first strategy...
    func loadLocations() async -> [Location] {
        // ... существующая реализация без изменений
        if let cached = locationsCache {
            lastDataSource["locations"] = "memory_cache"
            print("📦 [DataService] Locations из памяти (cache)")
            return cached
        }

        let local = await loadLocalLocations()
        if !local.isEmpty {
            locationsCache = local
            lastDataSource["locations"] = "local"
            print("📂 [DataService] Locations из локального JSON")
        }

        Task {
            do {
                let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
                self.locationsCache = locations
                self.lastDataSource["locations"] = "network"
                print("🌐 [DataService] Locations обновлены из сети")
            } catch {
                print("⚠️ [DataService] Ошибка загрузки Locations из сети: \(error)")
            }
        }

        return locationsCache ?? []
    }

    // 🔄 ОСТАВЛЯЕМ без изменений остальные методы:
    // - loadLocalArticles(), loadLocalCategories(), loadLocalLocations()
    // - clearCache(), refreshData(), getLastDataSource()

    // MARK: - Локальные fallback (асинхронные)
    
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

    // MARK: - Cache control

    /// Clears all cached data and resets the last data source information.
    func clearCache() {
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        networkService.clearCache()
        lastDataSource.removeAll()
        print("🗑️ [DataService] Кэш очищен")
    }
    
    /// Clears only articles cache while preserving categories and locations
    func clearArticlesCache() async {
        articlesCache = nil
        lastDataSource["articles"] = nil
        print("🗑️ [DataService] Articles cache cleared")
    }

    /// Clears only categories cache while preserving articles and locations
    func clearCategoriesCache() async {
        categoriesCache = nil
        lastDataSource["categories"] = nil
        print("🗑️ [DataService] Categories cache cleared")
    }

    /// Clears only locations cache while preserving articles and categories
    func clearLocationsCache() async {
        locationsCache = nil
        lastDataSource["locations"] = nil
        print("🗑️ [DataService] Locations cache cleared")
    }

    /// Forces a refresh by clearing caches and reloading all data.
    func refreshData() async {
        clearCache()
        _ = await loadArticles()
        _ = await loadCategories()
        _ = await loadLocations()
        print("🔄 [DataService] Данные обновлены")
    }

    // MARK: - API для UI

    /// Returns a dictionary containing the last used data source information for articles, categories, and locations.
    /// - Returns: Dictionary with keys as data types and values as the last data source string.
    func getLastDataSource() async -> [String: String] {
        return lastDataSource
    }
}
