//
//  CategoryManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  CategoryManager.swift
//  InGermany
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
    
    func category(for id: String) -> Category? {
        return categories.first { $0.id == id }
    }
    
    func category(for name: String, language: String = "en") -> Category? {
        return categories.first { $0.localizedName(for: language) == name }
    }
    
    func allCategories() -> [Category] {
        return categories
    }
}
