//
//  ArticlesRepositoryImpl.swift
//  InGermany
//

//
//  ArticlesRepositoryImpl.swift
//  InGermany
//

import Foundation

final class ArticlesRepositoryImpl: ArticlesRepositoryProtocol {
    private let dataService: DataService

    init(dataService: DataService = .shared) {
        self.dataService = dataService
    }

    func loadArticles() async -> [Article] {
        await dataService.loadArticles()
    }

    func refreshArticles() async -> [Article] {
        await dataService.refreshData()
        return await dataService.loadArticles()
    }

    func getLastSource() async -> String {
        let sources = await dataService.getLastDataSource()
        return sources["articles"] ?? "unknown"
    }
}
