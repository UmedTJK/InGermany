//  CategoriesRepositoryImpl.swift
//  InGermany
//
//  Refactored: removed singleton, injected DataService
//

import Foundation

@MainActor
final class CategoriesRepositoryImpl: ObservableObject, CategoriesRepositoryProtocol {

    @Published private(set) var categories: [Category] = []
    private var byId: [String: Category] = [:]

    private let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }

    func bootstrap() async {
        let list = await dataService.loadCategories()
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
