//
//  InGermanyTests.swift
//  InGermanyTests
//
//  Created by SUM TJK on 04.10.25.
//

import XCTest
@testable import InGermany

final class InGermanyTests: XCTestCase {

    func testAppLaunches() {
        let app = InGermanyApp()
        XCTAssertNotNil(app, "InGermanyApp should be initialized successfully")
    }

    @MainActor
    func testFavoritesManagerSingleton() {
        let manager = FavoritesManager.shared
        XCTAssertNotNil(manager, "FavoritesManager.shared should be accessible")
    }

    func testDataServiceLoadsArticles() async throws {
        let service = DataService.shared
        let articles = await service.loadArticles()
        XCTAssertFalse(articles.isEmpty, "DataService should load articles from bundled JSON")
    }
}
