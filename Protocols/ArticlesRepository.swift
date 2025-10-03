//
//  ArticlesRepository.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
import Foundation

/// Контракт репозитория статей. Без throws — строго под твой DataService.
protocol ArticlesRepository {
    /// Возвращает все статьи (локально/из кэша/как реализовано в DataService).
    func loadArticles() async -> [Article]

    /// Обновляет данные и возвращает актуальный список статей.
    func refreshArticles() async -> [Article]

    /// Возвращает источник данных для статей (например, "local", "remote").
    func getLastSource() async -> String
}
