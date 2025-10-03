//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

actor DataService {
    static let shared = DataService()

    private let networkService = NetworkService.shared
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?

    private var lastDataSource: [String: String] = [:]

    private init() {}

    // MARK: - Асинхронные методы (Offline-First)

    func loadArticles() async -> [Article] {
        if let cached = articlesCache {
            lastDataSource["articles"] = "memory_cache"
            print("📦 Articles из памяти (cache)")
            return cached
        }

        let localArticles = await loadLocalArticles()
        if !localArticles.isEmpty {
            articlesCache = localArticles
            lastDataSource["articles"] = "local"
            print("📂 Articles из локального JSON")
            print("🔎 Preview первых 3 статей:", Array(localArticles.prefix(3)))
        }

        Task {
            do {
                let articles: [Article] = try await networkService.loadJSON(from: "articles.json")
                self.articlesCache = articles
                self.lastDataSource["articles"] = "network"
                print("🌐 Articles обновлены из сети")
                print("🔎 Preview первых 3 статей (network):", Array(articles.prefix(3)))
            } catch {
                print("⚠️ Ошибка загрузки Articles из сети: \(error)")
            }
        }

        return articlesCache ?? []
    }

    func loadCategories() async -> [Category] {
        if let cached = categoriesCache {
            lastDataSource["categories"] = "memory_cache"
            print("📦 Categories из памяти (cache)")
            return cached
        }

        let local = await loadLocalCategories()
        if !local.isEmpty {
            categoriesCache = local
            lastDataSource["categories"] = "local"
            print("📂 Categories из локального JSON")
        }

        Task {
            do {
                let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
                self.categoriesCache = categories
                self.lastDataSource["categories"] = "network"
                print("🌐 Categories обновлены из сети")
            } catch {
                print("⚠️ Ошибка загрузки Categories из сети: \(error)")
            }
        }

        return categoriesCache ?? []
    }

    func loadLocations() async -> [Location] {
        if let cached = locationsCache {
            lastDataSource["locations"] = "memory_cache"
            print("📦 Locations из памяти (cache)")
            return cached
        }

        let local = await loadLocalLocations()
        if !local.isEmpty {
            locationsCache = local
            lastDataSource["locations"] = "local"
            print("📂 Locations из локального JSON")
        }

        Task {
            do {
                let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
                self.locationsCache = locations
                self.lastDataSource["locations"] = "network"
                print("🌐 Locations обновлены из сети")
            } catch {
                print("⚠️ Ошибка загрузки Locations из сети: \(error)")
            }
        }

        return locationsCache ?? []
    }

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

    func clearCache() {
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        networkService.clearCache()
        lastDataSource.removeAll()
        print("🗑️ Кэш очищен")
    }

    func refreshData() async {
        clearCache()
        _ = await loadArticles()
        _ = await loadCategories()
        _ = await loadLocations()
        print("🔄 Данные обновлены")
    }

    // MARK: - Новый API для UI

    func getLastDataSource() async -> [String: String] {
        return lastDataSource
    }
}
