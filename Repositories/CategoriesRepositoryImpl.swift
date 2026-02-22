//  CategoriesRepositoryImpl.swift
//  InGermany
//
//  Refactored: removed singleton, injected DataService
//

import Foundation

final class CategoriesRepositoryImpl: ObservableObject, CategoriesRepositoryProtocol {

    @MainActor @Published private(set) var categories: [Category] = []
    @MainActor private var byId: [String: Category] = [:]

    private let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }

    func bootstrap() async {
        let list = await dataService.loadCategories()
        await MainActor.run {
            self.categories = list
            self.byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
        }
    }

    func refresh() async {
        guard !Task.isCancelled else { return }
        await bootstrap()
    }

    @MainActor func category(by id: String) -> Category? {
        byId[id]
    }

    @MainActor func allCategories() -> [Category] {
        categories
    }
}
