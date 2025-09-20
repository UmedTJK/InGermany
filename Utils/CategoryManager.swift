//
//  CategoryManager.swift
//  InGermany
//

import Foundation

actor CategoryManager {
    // Разрешаем доступ к синглтону без изоляции актора (только к самому инстансу),
    // чтобы не ловить ошибки Swift 6 при обращении к .shared
    nonisolated(unsafe) static let shared = CategoryManager()

    private let dataService = DataService.shared
    private var categories: [Category] = []

    private init() {}

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

    /// Принудительное обновление
    func refreshCategories() async {
        await loadCategories()
    }
}
