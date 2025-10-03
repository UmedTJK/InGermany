//
//  CategoryManager.swift
//  InGermany
//

import Foundation

/// Actor, управляющий загрузкой и доступом к категориям статей.
/// Работает с `DataService` и поддерживает асинхронную модель `offline-first`.
actor CategoryManager {
    private let dataService = DataService.shared
    private var categories: [Category] = []

    /// Создаёт новый экземпляр менеджера категорий.
    init() {}

    /// Асинхронная загрузка категорий (локально или из сети через `DataService`).
    func loadCategories() async {
        categories = await dataService.loadCategories()
    }

    /// Возвращает текущий список категорий (снимок состояния).
    /// - Returns: Массив категорий.
    func allCategories() -> [Category] {
        categories
    }

    /// Ищет категорию по её уникальному идентификатору.
    /// - Parameter id: Уникальный идентификатор категории.
    /// - Returns: Найденная категория или `nil`, если не найдена.
    func category(for id: String) -> Category? {
        categories.first { $0.id == id }
    }

    /// Ищет категорию по локализованному имени.
    /// - Parameters:
    ///   - name: Локализованное название категории.
    ///   - language: Язык для сравнения (по умолчанию "en").
    /// - Returns: Найденная категория или `nil`, если не найдена.
    func category(for name: String, language: String = "en") -> Category? {
        categories.first { $0.localizedName(for: language) == name }
    }

    /// Принудительное обновление списка категорий:
    /// очищает кеш и заново загружает данные.
    func refreshCategories() async {
        await dataService.clearCache()
        await loadCategories()
    }
}

/// Глобальный экземпляр менеджера категорий (альтернатива паттерну `.shared`).
let categoryManager = CategoryManager()
