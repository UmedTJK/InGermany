//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()
    
    private let networkService = NetworkService.shared
    private var articlesCache: [Article]?
    private var categoriesCache: [Category]?
    private var locationsCache: [Location]?
    
    @Published var lastDataSource: [String: String] = [:]
    
    private init() {}
    
    // MARK: - Асинхронные методы
    
    func loadArticles() async -> [Article] {
        if let cached = articlesCache {
            lastDataSource["articles"] = "memory_cache"
            return cached
        }
        
        do {
            let articles: [Article] = try await networkService.loadJSON(from: "articles.json")
            articlesCache = articles
            lastDataSource["articles"] = "network"
            return articles
        } catch {
            let localArticles = loadLocalArticles()
            articlesCache = localArticles
            lastDataSource["articles"] = "local"
            return localArticles
        }
    }
    
    func loadCategories() async -> [Category] {
        if let cached = categoriesCache {
            lastDataSource["categories"] = "memory_cache"
            return cached
        }
        
        do {
            let categories: [Category] = try await networkService.loadJSON(from: "categories.json")
            categoriesCache = categories
            lastDataSource["categories"] = "network"
            return categories
        } catch {
            let local = loadLocalCategories()
            categoriesCache = local
            lastDataSource["categories"] = "local"
            return local
        }
    }
    
    func loadLocations() async -> [Location] {
        if let cached = locationsCache {
            lastDataSource["locations"] = "memory_cache"
            return cached
        }
        
        do {
            let locations: [Location] = try await networkService.loadJSON(from: "locations.json")
            locationsCache = locations
            lastDataSource["locations"] = "network"
            return locations
        } catch {
            let local = loadLocalLocations()
            locationsCache = local
            lastDataSource["locations"] = "local"
            return local
        }
    }
    
    // MARK: - Синхронные методы (оставлены для обратной совместимости)
    
    func loadArticles() -> [Article] {
        if let cached = articlesCache {
            DispatchQueue.main.async { self.lastDataSource["articles"] = "memory_cache" }
            return cached
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: [Article] = []
        
        networkService.loadJSONSync(from: "articles.json") { (res: Result<[Article], Error>) in
            switch res {
            case .success(let articles):
                result = articles
                self.articlesCache = articles
                DispatchQueue.main.async { self.lastDataSource["articles"] = "network" }
            case .failure:
                let local = self.loadLocalArticles()
                result = local
                self.articlesCache = local
                DispatchQueue.main.async { self.lastDataSource["articles"] = "local" }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    func loadCategories() -> [Category] {
        if let cached = categoriesCache {
            DispatchQueue.main.async { self.lastDataSource["categories"] = "memory_cache" }
            return cached
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: [Category] = []
        
        networkService.loadJSONSync(from: "categories.json") { (res: Result<[Category], Error>) in
            switch res {
            case .success(let categories):
                result = categories
                self.categoriesCache = categories
                DispatchQueue.main.async { self.lastDataSource["categories"] = "network" }
            case .failure:
                let local = self.loadLocalCategories()
                result = local
                self.categoriesCache = local
                DispatchQueue.main.async { self.lastDataSource["categories"] = "local" }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    func loadLocations() -> [Location] {
        if let cached = locationsCache {
            DispatchQueue.main.async { self.lastDataSource["locations"] = "memory_cache" }
            return cached
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: [Location] = []
        
        networkService.loadJSONSync(from: "locations.json") { (res: Result<[Location], Error>) in
            switch res {
            case .success(let locations):
                result = locations
                self.locationsCache = locations
                DispatchQueue.main.async { self.lastDataSource["locations"] = "network" }
            case .failure:
                let local = self.loadLocalLocations()
                result = local
                self.locationsCache = local
                DispatchQueue.main.async { self.lastDataSource["locations"] = "local" }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    // MARK: - Вспомогательные методы
    
    func getArticles(for categoryId: String) -> [Article] {
        return loadArticles().filter { $0.categoryId == categoryId }
    }
    
    func getArticles(with tag: String) -> [Article] {
        return loadArticles().filter { $0.tags.contains(tag) }
    }
    
    func getArticle(by id: String) -> Article? {
        return loadArticles().first { $0.id == id }
    }
    
    // MARK: - Локальные fallback
    
    private func loadLocalArticles() -> [Article] {
        guard let file = Bundle.main.url(forResource: "articles", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: file)
            return try JSONDecoder().decode([Article].self, from: data)
        } catch {
            return []
        }
    }
    
    private func loadLocalCategories() -> [Category] {
        guard let file = Bundle.main.url(forResource: "categories", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: file)
            return try JSONDecoder().decode([Category].self, from: data)
        } catch {
            return []
        }
    }
    
    private func loadLocalLocations() -> [Location] {
        guard let file = Bundle.main.url(forResource: "locations", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: file)
            return try JSONDecoder().decode([Location].self, from: data)
        } catch {
            return []
        }
    }
    
    // MARK: - Cache control
    
    func clearCache() {
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        networkService.clearCache()
    }
    
    func refreshData() async {
        articlesCache = nil
        categoriesCache = nil
        locationsCache = nil
        _ = await loadArticles()
        _ = await loadCategories()
        _ = await loadLocations()
    }
}
