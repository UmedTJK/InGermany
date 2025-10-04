//
//  CategoryManagerTests.swift
//  InGermanyTests
//
//  Created by SUM TJK on 04.10.25.
//

import XCTest
@testable import InGermany

final class CategoryManagerTests: XCTestCase {

    var sut: CategoryManager!

    override func setUp() async throws {
        sut = CategoryManager()
        await sut.loadCategories()
    }

    override func tearDown() async throws {
        sut = nil
    }

    func testLoadCategoriesNotEmpty() async throws {
        let categories = await sut.allCategories()
        XCTAssertFalse(categories.isEmpty, "CategoryManager should load categories")
    }

    func testFindCategoryById() async throws {
        let categories = await sut.allCategories()
        guard let first = categories.first else {
            XCTFail("No categories loaded")
            return
        }

        let found = await sut.category(for: first.id)
        XCTAssertNotNil(found, "Should find category by id")
        XCTAssertEqual(found?.id, first.id)
    }

    func testFindCategoryByName() async throws {
        let categories = await sut.allCategories()
        guard let first = categories.first else {
            XCTFail("No categories loaded")
            return
        }

        let name = first.localizedName(for: "en")
        let found = await sut.category(for: name, language: "en")
        XCTAssertNotNil(found, "Should find category by localized name")
        XCTAssertEqual(found?.id, first.id)
    }

    func testFindCategoryByInvalidIdReturnsNil() async throws {
        let found = await sut.category(for: "non-existing-id")
        XCTAssertNil(found, "Should return nil for non-existing id")
    }

    func testFindCategoryByInvalidNameReturnsNil() async throws {
        let found = await sut.category(for: "NonExistingName", language: "en")
        XCTAssertNil(found, "Should return nil for non-existing localized name")
    }

    func testCategoriesHaveUniqueIds() async throws {
        let categories = await sut.allCategories()
        let ids = categories.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "Category IDs should be unique")
    }

    func testRefreshCategoriesReloadsData() async throws {
        // Загружаем категории первый раз
        let initialCategories = await sut.allCategories()
        XCTAssertFalse(initialCategories.isEmpty, "Initial categories should not be empty")

        // Вызываем refreshCategories()
        await sut.refreshCategories()

        // Загружаем категории снова
        let refreshedCategories = await sut.allCategories()
        XCTAssertFalse(refreshedCategories.isEmpty, "Refreshed categories should not be empty")

        // Проверяем, что массивы идентификаторов совпадают по количеству
        XCTAssertEqual(initialCategories.count, refreshedCategories.count, "Category counts should be the same after refresh")
    }
}
