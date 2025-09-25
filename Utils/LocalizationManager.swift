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
            "Главная": [
                "ru": "Главная",
                "en": "Home",
                "de": "Startseite",
                "tj": "Саҳифаи асосӣ",
                "fa": "خانه",
                "ar": "الرئيسية",
                "uk": "Головна"
            ],
            "Категории": [
                "ru": "Категории",
                "en": "Categories",
                "de": "Kategorien",
                "tj": "Категорияҳо",
                "fa": "دسته‌ها",
                "ar": "الفئات",
                "uk": "Категорії"
            ],
            "Поиск": [
                "ru": "Поиск",
                "en": "Search",
                "de": "Suche",
                "tj": "Ҷустуҷӯ",
                "fa": "جستجو",
                "ar": "بحث",
                "uk": "Пошук"
            ],
            "Избранное": [
                "ru": "Избранное",
                "en": "Favorites",
                "de": "Favoriten",
                "tj": "Интихобшуда",
                "fa": "علاقه‌مندی‌ها",
                "ar": "المفضلة",
                "uk": "Вибране"
            ],
            "Настройки": [
                "ru": "Настройки",
                "en": "Settings",
                "de": "Einstellungen",
                "tj": "Танзимот",
                "fa": "تنظیمات",
                "ar": "الإعدادات",
                "uk": "Налаштування"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
