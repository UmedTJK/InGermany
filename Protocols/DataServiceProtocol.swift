//
//  DataServiceProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 20.02.26.
//

import Foundation

protocol DataServiceProtocol {
    func loadArticles() async -> [Article]
    func loadArticlesWithSource() async -> ([Article], String)

    func loadCategories() async -> [Category]
    func loadLocations() async -> [Location]

    func getLastDataSource() async -> [String: String]

    func clearCache() async
    func clearArticlesCache() async
}
