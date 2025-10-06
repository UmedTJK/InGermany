//
//  NetworkServiceTests.swift
//  InGermany
//
//  Created by SUM TJK on 06.10.25.
//

import XCTest
@testable import InGermany

final class NetworkServiceTests: XCTestCase {
    func testOfflineFirstStrategy() async throws {
        let service = NetworkService.shared
        
        // Тест должен проходить даже без сети (использует Bundle)
        let articles: [Article] = try await service.loadJSON(from: "articles.json") // 🔧 Явно указали тип
        
        XCTAssertFalse(articles.isEmpty, "Должны загрузиться статьи из Bundle")
    }
    
    func testDataSourceTracking() async throws {
        let service = NetworkService.shared
        
        // 🔧 Явно указали тип возвращаемого значения
        let (articles, source): ([Article], NetworkService.DataSource) = try await service.loadJSONWithSource(from: "articles.json")
        
        XCTAssertFalse(articles.isEmpty)
        // Источник должен быть bundle или file_cache (но не network для первого вызова)
        XCTAssertTrue([NetworkService.DataSource.bundle, .fileCache].contains(source), // 🔧 Полный путь к enum
                     "Source should be bundle or fileCache, but was \(source)")
    }
}
