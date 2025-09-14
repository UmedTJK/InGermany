//
//  CategoryManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

// CategoryManager.swift - СОЗДАЙТЕ НОВЫЙ ФАЙЛ
//
//  CategoryManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    
    private let dataService = DataService.shared
    private var categories: [Category] = []
    
    private init() {
        loadCategories()
    }
    
    func loadCategories() {
        categories = dataService.loadCategories()
    }
    
    func category(for id: String) -> Category? { // Измените на String
        return categories.first { $0.id == id }
    }
    
    func allCategories() -> [Category] {
        return categories
    }
}
