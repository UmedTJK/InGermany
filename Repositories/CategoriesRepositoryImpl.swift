//  CategoryManager.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//

import Foundation

@MainActor
final class CategoriesRepositoryImpl: ObservableObject, CategoriesRepositoryProtocol {
    static let shared = CategoriesRepositoryImpl()

    @Published private(set) var categories: [Category] = []
    private var byId: [String: Category] = [:]

    private init() {}

    func bootstrap() async {
        let list = await DataService.shared.loadCategories()
        categories = list
        byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    func refresh() async {
        await bootstrap()
    }

    func category(by id: String) -> Category? {
        byId[id]
    }

    func allCategories() -> [Category] {
        categories
    }
}
