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
        print("🔄 [CategoriesRepository] Начинаем загрузку категорий...")
        let list = await DataService.shared.loadCategories()
        
        // 🔍 ДОБАВЛЕНО: Подробная отладочная информация
        print("🔍 [DEBUG] Получено категорий от DataService: \(list.count)")
        
        if list.isEmpty {
            print("❌ [DEBUG] DataService вернул пустой список категорий")
        } else {
            print("✅ [DEBUG] Категории успешно загружены:")
            for (index, category) in list.enumerated().prefix(3) {
                print("   \(index + 1). \(category.id) - \(category.localizedName(for: "ru")) (icon: \(category.icon), color: \(category.colorHex))")
            }
            if list.count > 3 {
                print("   ... и еще \(list.count - 3) категорий")
            }
        }
        
        categories = list
        byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
        
        print("✅ [CategoriesRepository] Загрузка завершена: \(categories.count) категорий, \(byId.count) в словаре")
    }

    /// Обновление данных
    func refresh() async {
        print("🔄 [CategoriesRepository] Обновляем категории...")
        await bootstrap()
    }

    /// Получить категорию по ID
    func category(by id: String) -> Category? {
        let result = byId[id]
        if result == nil {
            print("⚠️ [CategoriesRepository] Категория с ID '\(id)' не найдена")
        }
        return result
    }

    /// Получить все категории
    func allCategories() -> [Category] {
        print("📋 [CategoriesRepository] Запрошены все категории: \(categories.count) шт")
        return categories
    }
}
