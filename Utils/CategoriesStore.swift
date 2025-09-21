//
//  CategoriesStore.swift
//  InGermany
//

import Foundation
import SwiftUI

@MainActor
final class CategoriesStore: ObservableObject {
    static let shared = CategoriesStore()

    @Published private(set) var categories: [Category] = []
    @Published private(set) var byId: [String: Category] = [:]

    init() {} // Убрали private

    /// Инициализирующая загрузка из CategoryManager (actor)
    func bootstrap() async {
        await categoryManager.loadCategories()
        let list = await categoryManager.allCategories()
        categories = list
        byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    /// Обновление (повторная подгрузка)
    func refresh() async {
        await categoryManager.refreshCategories()
        let list = await categoryManager.allCategories()
        categories = list
        byId = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    /// Утилиты для вью
    func category(for id: String) -> Category? { byId[id] }

    func categoryName(for id: String, language: String = "ru") -> String {
        byId[id]?.localizedName(for: language) ?? "—"
    }
}
