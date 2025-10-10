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
    /// Текущий список категорий (доступно только из главного актора)
    var categories: [Category] { get }
    
    /// Инициализирующая загрузка категорий
    func bootstrap() async
    
    /// Обновление данных категорий
    func refresh() async
    
    /// Получить категорию по ID
    func category(by id: String) -> Category?
    
    /// Получить все категории
    func allCategories() -> [Category]
}

@MainActor
final class DefaultCategoriesRepository: ObservableObject, CategoriesRepositoryProtocol {
    static let shared = DefaultCategoriesRepository()

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
