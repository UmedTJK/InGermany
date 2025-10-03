//
//  ArticlesRepositoryImpl.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
import Foundation

/// Реализация репозитория поверх существующего DataService.
/// Никакой новой логики — просто тонкая прокладка (адаптер).
final class ArticlesRepositoryImpl: ArticlesRepository {
    func loadArticles() async -> [Article] {
        await DataService.shared.loadArticles()
    }

    func refreshArticles() async -> [Article] {
        await DataService.shared.refreshData()
        return await DataService.shared.loadArticles()
    }

    func getLastSource() async -> String {
        let sources = await DataService.shared.getLastDataSource()
        return sources["articles"] ?? "unknown"
    }
}
