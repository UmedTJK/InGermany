//
//  CategoriesViewModelTests.swift
//  InGermany
//
//  Created by SUM TJK on 04.10.25.
//

import XCTest
@testable import InGermany

@MainActor
final class CategoriesViewModelTests: XCTestCase {
    var sut: CategoriesViewModel!
    var mockCategoriesRepo: MockCategoriesRepository!
    var mockArticlesRepo: MockArticlesRepository!

    override func setUp() async throws {
        try await super.setUp()
        mockCategoriesRepo = MockCategoriesRepository()
        mockArticlesRepo = MockArticlesRepository()
        sut = CategoriesViewModel(
            categoriesRepo: mockCategoriesRepo,
            articlesRepo: mockArticlesRepo
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockCategoriesRepo = nil
        mockArticlesRepo = nil
        try await super.tearDown()
    }

    func testLoadLoadsCategories() async {
        await sut.load()
        XCTAssertEqual(sut.categories.count, 2)
        XCTAssertEqual(sut.categories.first?.id, "c1")
    }

    func testLoadArticlesLoadsArticles() async {
        await sut.loadData()
        XCTAssertEqual(sut.articles.count, 2)
    }

    func testArticlesForCategoryReturnsCorrectResults() async {
        await sut.loadData()
        let filtered = sut.articles(for: "c1")
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, "a1")
    }
}
