//
//  Category.swift
//  InGermany
//

import Foundation

/// Represents an article category with localized names, icon, and color.
struct Category: Identifiable, Codable, Hashable {
    /// Unique identifier of the category.
    let id: String
    /// Localized names of the category by language code.
    let name: [String: String]
    /// SF Symbol name representing the category.
    let icon: String
    /// Hexadecimal color string associated with the category.
    let colorHex: String
    
    /// Returns the localized name for the given language, with fallback to English or first available value.
    func localizedName(for language: String) -> String {
        name[language] ?? name["en"] ?? name.values.first ?? "No name"
    }
}

// MARK: - Sample Data for Preview

extension Category {
    static let sampleCategories: [Category] = [
        Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance"],
            icon: "banknote",
            colorHex: "#4A90E2"
        ),
        Category(
            id: "22222222-2222-2222-2222-bbbbbbbbbbbb",
            name: ["ru": "Работа", "en": "Work"],
            icon: "briefcase",
            colorHex: "#27AE60"
        )
    ]
}
