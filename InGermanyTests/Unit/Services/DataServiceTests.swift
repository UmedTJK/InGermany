//
//  DataServiceTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

final class DataServiceTests: XCTestCase {
    func testLoadArticles() async {
        let dataService = DataService.shared
        let articles = await dataService.loadArticles()
        XCTAssertFalse(articles.isEmpty, "Articles should not be empty")
    }

    func testRefreshArticles() async {
        let dataService = DataService.shared
        await dataService.refreshData()
        let articles = await dataService.loadArticles()
        XCTAssertFalse(articles.isEmpty, "Articles should not be empty after refresh")
    }
}
