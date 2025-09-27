//
//  CategoryManager.swift
//  InGermany
//

import Foundation

actor CategoryManager {
    private let dataService = DataService.shared
    private var categories: [Category] = []

    init() {}

    /// Асинхронная загрузка категорий (из сети/локально через DataService)
    func loadCategories() async {
        categories = await dataService.loadCategories()
    }

    /// Все категории (снимок текущего состояния)
    func allCategories() -> [Category] {
        categories
    }

    /// Поиск по id
    func category(for id: String) -> Category? {
        categories.first { $0.id == id }
    }

    /// Поиск по локализованному имени
    func category(for name: String, language: String = "en") -> Category? {
        categories.first { $0.localizedName(for: language) == name }
    }

    /// Принудительное обновление (очистка кеша и повторная загрузка)
    func refreshCategories() async {
        await dataService.clearCache()
        await loadCategories()
    }
}

// ✅ Глобальный экземпляр (вместо .shared)
let categoryManager = CategoryManager()
