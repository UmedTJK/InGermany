//
//  ArticleEditorViewModelTests.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//
//
//  ArticleEditorViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class ArticleEditorViewModelTests: XCTestCase {

    func testExportToJSON_includesTitleAndBlocks() async throws {
        // Arrange
        let vm = ArticleEditorViewModel(title: "Test Article")

        // Добавляем блоки
        vm.addBlock(type: .paragraph)
        vm.blocks[0].payload = .content("Hello world")

        vm.addBlock(type: .info)
        vm.blocks[1].payload = .content("Some info")

        // Act
        let data = try vm.exportToJSON()

        // Assert
        let decoded = try JSONDecoder().decode(ArticleDocument.self, from: data)

        XCTAssertEqual(decoded.title, "Test Article")
        XCTAssertEqual(decoded.blocks.count, 2)
        XCTAssertEqual(decoded.blocks[0].type, "paragraph")
        XCTAssertEqual(decoded.blocks[0].content, "Hello world")
        XCTAssertEqual(decoded.blocks[1].type, "info")
        XCTAssertEqual(decoded.blocks[1].content, "Some info")
    }
}
