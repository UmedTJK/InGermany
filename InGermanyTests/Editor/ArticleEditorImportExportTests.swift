//
//  ArticleEditorImportExportTests.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

//
//  ArticleEditorImportExportTests.swift
//  InGermanyTests
//
//  Created by SUM TJK on 13.10.25.
//

import XCTest
@testable import InGermany

@MainActor
final class ArticleEditorImportExportTests: XCTestCase {

    func testExportImportSymmetry() throws {
        // 1. Создаем ViewModel с демо-данными
        let vm = ArticleEditorViewModel(title: "Test Article")
        vm.addBlock(type: .paragraph)
        vm.blocks[0].payload = .content("Hello World")
        vm.addBlock(type: .list)
        if case .list(var items) = vm.blocks[1].payload {
            items[0] = "Item 1"
            vm.blocks[1].payload = .list(items)
        }

        // 2. Экспортируем в JSON
        let data = try vm.exportToJSON()

        // 3. Новый ViewModel — чистый
        let vm2 = ArticleEditorViewModel()

        // 4. Импортируем JSON
        try vm2.importFromJSON(data)

        // 5. Проверяем, что title и blocks совпадают
        XCTAssertEqual(vm2.title, vm.title)
        XCTAssertEqual(vm2.blocks.count, vm.blocks.count)

        // сравнение payload-ов
        for (a, b) in zip(vm.blocks, vm2.blocks) {
            XCTAssertEqual(a.type, b.type)
            XCTAssertEqual(a.payload, b.payload)
        }
    }
}
