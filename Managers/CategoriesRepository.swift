//
//  CategoriesRepository.swift
//  InGermany
//
//  Created by SUM TJK on 27.09.25.
//
//
//  CategoriesRepository.swift
//  InGermany
//

import Foundation
import Combine

/// Репозиторий категорий, объединяющий загрузку и хранение
@MainActor
final class CategoriesRepository: ObservableObject {
    static let shared = CategoriesRepository()

    @Published private(set) var categories: [Category] = []
    private var byId: [String: Category] = [:]

    private init() {}

    /// Инициализирующая загрузка категорий
    func bootstrap() async {
        do {
            let list = try await DataService.shared.loadCategories()
            categories = list
            byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
        } catch {
            print("❌ Ошибка загрузки категорий: \(error)")
            categories = []
            byId = [:]
        }
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

