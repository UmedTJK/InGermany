//
//  CategoriesRepositoryProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 27.09.25.
//

import Foundation
import Combine

/// Репозиторий категорий, объединяющий загрузку и хранение
@MainActor
protocol CategoriesRepositoryProtocol {
    var categories: [Category] { get }
    func bootstrap() async
    func refresh() async
    func category(by id: String) -> Category?
    func allCategories() -> [Category]
}

@MainActor
final class DefaultCategoriesRepository: ObservableObject, CategoriesRepositoryProtocol {
    static let shared = DefaultCategoriesRepository()

    @Published private(set) var categories: [Category] = []
    private var byId: [String: Category] = [:]

    private init() {}

    /// Инициализирующая загрузка категорий
    func bootstrap() async {
        let list = await DataService.shared.loadCategories()
        categories = list
        byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    /// Обновление данных
    func refresh() async {
        await bootstrap()
    }

    /// Получить категорию по ID
    func category(by id: String) -> Category? {
        byId[id]
    }

    /// Получить все категории
    func allCategories() -> [Category] {
        categories
    }
}
