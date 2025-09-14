//
//  Category.swift
//  InGermany
//
import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: [String: String]
    let icon: String
    
    func localizedName(for language: String) -> String {
        name[language] ?? name["en"] ?? name.values.first ?? "No name"
    }
}

// Пример для превью
extension Category {
    static let sampleCategories: [Category] = [
        Category(
            id: "11111111-1111-1111-1111-aaaaaaaaaaaa",
            name: ["ru": "Финансы", "en": "Finance"],
            icon: "banknote"
        ),
        Category(
            id: "22222222-2222-2222-2222-bbbbbbbbbbbb",
            name: ["ru": "Работа", "en": "Work"],
            icon: "briefcase"
        )
    ]
}
