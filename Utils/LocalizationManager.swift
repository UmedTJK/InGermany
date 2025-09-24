//
//  LocalizationManager.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
//  LocalizationManager.swift
//  InGermany
//

import SwiftUI

final class LocalizationManager {
    static let shared = LocalizationManager()

    private init() {}

    func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            // 🔹 Tab bar
            "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Саҳифаи асосӣ"],
            "Категории": ["ru": "Категории", "en": "Categories", "de": "Kategorien", "tj": "Категорияҳо"],
            "Поиск": ["ru": "Поиск", "en": "Search", "de": "Suche", "tj": "Ҷустуҷӯ"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Настройки": ["ru": "Настройки", "en": "Settings", "de": "Einstellungen", "tj": "Танзимот"]
        ]
        return translations[key]?[language] ?? key
    }
}
