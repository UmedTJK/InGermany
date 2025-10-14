//
//  MockCategoriesRepository.swift
//  InGermany
//
//  Created by SUM TJK on 04.10.25.
//
@testable import InGermany

@MainActor
final class MockCategoriesRepository: CategoriesRepositoryProtocol {
    var categories: [Category] = [
        Category(id: "c1", name: ["en": "Health"], icon: "heart", colorHex: "#FF0000"),
        Category(id: "c2", name: ["en": "Work"], icon: "briefcase", colorHex: "#00FF00")
    ]

    func bootstrap() async {}
    func refresh() async {}
    func category(by id: String) -> Category? {
        categories.first { $0.id == id }
    }

    func allCategories() -> [Category] {
        categories
    }
}
