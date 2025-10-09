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
    
    // 🔄 СОХРАНЯЕМ: Существующие кэши для обратной совместимости
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    private var lastDataSource: [String: String] = [:]
    
    // 🔄 ДОБАВЛЯЕМ: Константы для ключей кэша
    private enum CacheKeys {
        static let articles = "articles"
        static let categories = "categories"
        static let locations = "locations"
    }

    private init() {}

    // MARK: - Асинхронные методы (Unified Offline-First)

    /// Loads articles with unified offline-first strategy:
    /// Memory Cache → NetworkService (Bundle → File Cache → Network)
    /// - Returns: Array of Article objects.
    func loadArticles() async -> [Article] {
        // 🔄 УЛУЧШЕНО: Единая стратегия через CacheManager
        if let cached: [Article] = await cacheManager.get(CacheKeys.articles) {
            lastDataSource["articles"] = "memory_cache"
            print("📦 [DataService] Articles из унифицированного кэша")
            
            // 🔄 СОХРАНЯЕМ: Асинхронное обновление
            Task {
                await refreshArticlesIfNeeded()
            }
            
            // 🔄 СОХРАНЯЕМ: Совместимость со старым кэшем
            articlesCache = cached
            
            // 🔍 ДОБАВЛЕНО: Отладочная информация
            print("🔍 [DEBUG] Загружено статей из кэша: \(cached.count)")
            if !cached.isEmpty {
                print("✅ [DEBUG] Первая статья из кэша: \(cached[0].id) - \(cached[0].localizedTitle(for: "ru"))")
            }
            
            return cached
        }

        // 🔄 УЛУЧШЕНО: Используем NetworkService как единый источник
        do {
            let (articles, source): ([Article], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "articles.json")
            
            // 🔄 СОХРАНЯЕМ: Все уровни кэширования
            await cacheManager.set(CacheKeys.articles, value: articles)
            articlesCache = articles
            lastDataSource["articles"] = source.rawValue
            
            print("📥 [DataService] Articles загружены из: \(source)")
            
            // 🔍 ДОБАВЛЕНО: Отладочная информация
            print("🔍 [DEBUG] Загружено статей: \(articles.count)")
            if articles.isEmpty {
                print("❌ [DEBUG] Статьи не загружены - проверьте структуру JSON")
            } else {
                print("✅ [DEBUG] Первая статья: \(articles[0].id) - \(articles[0].localizedTitle(for: "ru"))")
                print("✅ [DEBUG] Поля статьи: title=\(articles[0].title.count) языков, content=\(articles[0].content.count) языков, categoryId=\(articles[0].categoryId)")
            }
            
            return articles
            
        } catch {
            print("⚠️ [DataService] Ошибка загрузки Articles: \(error)")
            
            // 🔄 СОХРАНЯЕМ: Fallback на локальные данные если NetworkService не сработал
            let localArticles = await loadLocalArticles()
            if !localArticles.isEmpty {
                await cacheManager.set(CacheKeys.articles, value: localArticles)
                articlesCache = localArticles
                lastDataSource["articles"] = "local_fallback"
                print("🔄 [DataService] Articles из локального fallback")
                
                // 🔍 ДОБАВЛЕНО: Отладочная информация для fallback
                print("🔍 [DEBUG] Fallback статей: \(localArticles.count)")
                if !localArticles.isEmpty {
                    print("✅ [DEBUG] Первая fallback статья: \(localArticles[0].id) - \(localArticles[0].localizedTitle(for: "ru"))")
                }
                
                return localArticles
            }
            
            print("❌ [DEBUG] Нет статей даже в fallback")
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
            print("📦 [DataService] Categories из унифицированного кэша")
            
            Task {
                await refreshCategoriesIfNeeded()
            }
            
            categoriesCache = cached
            
            // 🔍 ДОБАВЛЕНО: Отладочная информация
            print("🔍 [DEBUG] Загружено категорий из кэша: \(cached.count)")
            if !cached.isEmpty {
                print("✅ [DEBUG] Первая категория из кэша: \(cached[0].id) - \(cached[0].localizedName(for: "ru"))")
            }
            
            return cached
        }

        do {
            let (categories, source): ([Category], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "categories.json")
            
            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = source.rawValue
            
            print("📥 [DataService] Categories загружены из: \(source)")
            
            // 🔍 ДОБАВЛЕНО: Отладочная информация
            print("🔍 [DEBUG] Загружено категорий: \(categories.count)")
            if categories.isEmpty {
                print("❌ [DEBUG] Категории не загружены - проверьте структуру JSON")
            } else {
                print("✅ [DEBUG] Первая категория: \(categories[0].id) - \(categories[0].localizedName(for: "ru"))")
                print("✅ [DEBUG] Поля категории: name=\(categories[0].name.count) языков, icon=\(categories[0].icon), colorHex=\(categories[0].colorHex)")
            }
            
            return categories
            
        } catch {
            print("⚠️ [DataService] Ошибка загрузки Categories: \(error)")
            
            let localCategories = await loadLocalCategories()
            if !localCategories.isEmpty {
                await cacheManager.set(CacheKeys.categories, value: localCategories)
                categoriesCache = localCategories
                lastDataSource["categories"] = "local_fallback"
                print("🔄 [DataService] Categories из локального fallback")
                
                // 🔍 ДОБАВЛЕНО: Отладочная информация для fallback
                print("🔍 [DEBUG] Fallback категорий: \(localCategories.count)")
                if !localCategories.isEmpty {
                    print("✅ [DEBUG] Первая fallback категория: \(localCategories[0].id) - \(localCategories[0].localizedName(for: "ru"))")
                }
                
                return localCategories
            }
            
            print("❌ [DEBUG] Нет категорий даже в fallback")
            return []
        }
    }

    /// Loads locations with unified offline-first strategy
    func loadLocations() async -> [Location] {
        if let cached: [Location] = await cacheManager.get(CacheKeys.locations) {
            lastDataSource["locations"] = "memory_cache"
            print("📦 [DataService] Locations из унифицированного кэша")
            
            Task {
                await refreshLocationsIfNeeded()
            }
            
            locationsCache = cached
            return cached
        }

        do {
            let (locations, source): ([Location], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "locations.json")
            
            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = source.rawValue
            
            print("📥 [DataService] Locations загружены из: \(source)")
            return locations
            
        } catch {
            print("⚠️ [DataService] Ошибка загрузки Locations: \(error)")
            
            let localLocations = await loadLocalLocations()
            if !localLocations.isEmpty {
                await cacheManager.set(CacheKeys.locations, value: localLocations)
                locationsCache = localLocations
                lastDataSource["locations"] = "local_fallback"
                print("🔄 [DataService] Locations из локального fallback")
                return localLocations
            }
            
            return []
        }
    }

    // MARK: - Умное обновление (сохраненная логика)

    private func refreshArticlesIfNeeded() async {
        do {
            let (articles, source): ([Article], NetworkService.DataSource) =
                try await networkService.loadJSONWithSource(from: "articles.json")
            
            // 🔄 СОХРАНЯЕМ: Обновляем только если данные с сети
            if source == .network {
                await cacheManager.set(CacheKeys.articles, value: articles)
                articlesCache = articles
                lastDataSource["articles"] = source.rawValue
                print("🔄 [DataService] Articles обновлены из сети")
            }
        } catch {
            print("⚠️ [DataService] Не удалось обновить Articles: \(error)")
        }
    }

    private func refreshCategoriesIfNeeded() async {
        do {
            let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
            await cacheManager.set(CacheKeys.categories, value: categories)
            categoriesCache = categories
            lastDataSource["categories"] = "network"
            print("🌐 [DataService] Categories обновлены из сети")
        } catch {
            print("⚠️ [DataService] Ошибка обновления Categories: \(error)")
        }
    }

    private func refreshLocationsIfNeeded() async {
        do {
            let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
            await cacheManager.set(CacheKeys.locations, value: locations)
            locationsCache = locations
            lastDataSource["locations"] = "network"
            print("🌐 [DataService] Locations обновлены из сети")
        } catch {
            print("⚠️ [DataService] Ошибка обновления Locations: \(error)")
        }
    }

    // MARK: - Локальные fallback (СОХРАНЯЕМ без изменений)
    
    private func loadLocalArticles() async -> [Article] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let file = Bundle.main.url(forResource: "articles", withExtension: "json") else {
                    print("❌ [DEBUG] Файл articles.json не найден в Bundle")
                    continuation.resume(returning: [])
                    return
                }
                do {
                    let data = try Data(contentsOf: file)
                    print("✅ [DEBUG] articles.json найден, размер: \(data.count) байт")
                    let decoded = try JSONDecoder().decode([Article].self, from: data)
                    print("✅ [DEBUG] articles.json успешно декодирован: \(decoded.count) статей")
                    continuation.resume(returning: decoded)
                } catch {
                    print("❌ [DEBUG] Ошибка декодирования articles.json: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func loadLocalCategories() async -> [Category] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let file = Bundle.main.url(forResource: "categories", withExtension: "json") else {
                    print("❌ [DEBUG] Файл categories.json не найден в Bundle")
                    continuation.resume(returning: [])
                    return
                }
                do {
                    let data = try Data(contentsOf: file)
                    print("✅ [DEBUG] categories.json найден, размер: \(data.count) байт")
                    let decoded = try JSONDecoder().decode([Category].self, from: data)
                    print("✅ [DEBUG] categories.json успешно декодирован: \(decoded.count) категорий")
                    continuation.resume(returning: decoded)
                } catch {
                    print("❌ [DEBUG] Ошибка декодирования categories.json: \(error)")
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

    // MARK: - Cache control (СОХРАНЯЕМ ВСЕ методы)

    /// Clears all cached data and resets the last data source information.
    func clearCache() {
        // 🔄 УЛУЧШЕНО: Очищаем все уровни кэширования
        Task {
            await cacheManager.clear()
        }
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        networkService.clearCache()
        lastDataSource.removeAll()
        print("🗑️ [DataService] Кэш очищен на всех уровнях")
    }
    
    /// Clears only articles cache while preserving categories and locations
    func clearArticlesCache() async {
        await cacheManager.clear(CacheKeys.articles)
        articlesCache = nil
        lastDataSource["articles"] = nil
        print("🗑️ [DataService] Articles cache cleared")
    }

    /// Clears only categories cache while preserving articles and locations
    func clearCategoriesCache() async {
        await cacheManager.clear(CacheKeys.categories)
        categoriesCache = nil
        lastDataSource["categories"] = nil
        print("🗑️ [DataService] Categories cache cleared")
    }

    /// Clears only locations cache while preserving articles and categories
    func clearLocationsCache() async {
        await cacheManager.clear(CacheKeys.locations)
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

    // MARK: - API для UI (СОХРАНЯЕМ без изменений)

    /// Returns a dictionary containing the last used data source information for articles, categories, and locations.
    /// - Returns: Dictionary with keys as data types and values as the last data source string.
    func getLastDataSource() async -> [String: String] {
        return lastDataSource
    }
}
