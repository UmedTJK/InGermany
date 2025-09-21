//
//  LocalizationManager.swift
//  InGermany
//

import Foundation

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    private init() {}

    /// Текущий выбранный язык (по умолчанию русский)
    @Published var selectedLanguage: String = "ru"

    /// Словарь переводов
    private let translations: [String: [String: String]] = [
        // MARK: - TabView
        "HomeTab": [
            "ru": "Главная",
            "en": "Home",
            "de": "Startseite",
            "tj": "Саҳифаи асосӣ"
        ],
        "CategoriesTab": [
            "ru": "Категории",
            "en": "Categories",
            "de": "Kategorien",
            "tj": "Категорияҳо"
        ],
        "SearchTab": [
            "ru": "Поиск",
            "en": "Search",
            "de": "Suche",
            "tj": "Ҷустуҷӯ"
        ],
        "FavoritesTab": [
            "ru": "Избранное",
            "en": "Favorites",
            "de": "Favoriten",
            "tj": "Интихобшуда"
        ],
        "SettingsTab": [
            "ru": "Настройки",
            "en": "Settings",
            "de": "Einstellungen",
            "tj": "Танзимот"
        ],
        "AboutTab": [
            "ru": "О проекте",
            "en": "About",
            "de": "Über das Projekt",
            "tj": "Дар бораи лоиҳа"
        ],

        // MARK: - Sections
        "AllArticles": [
            "ru": "Все статьи",
            "en": "All Articles",
            "de": "Alle Artikel",
            "tj": "Ҳамаи мақолаҳо"
        ],
        "RecentlyRead": [
            "ru": "Недавно прочитанное",
            "en": "Recently Read",
            "de": "Kürzlich gelesen",
            "tj": "Хондашудаи охирин"
        ],
        "UsefulTools": [
            "ru": "Полезные инструменты",
            "en": "Useful Tools",
            "de": "Nützliche Werkzeuge",
            "tj": "Абзорҳои муфид"
        ],
        "Map": [
            "ru": "Карта",
            "en": "Map",
            "de": "Karte",
            "tj": "Харита"
        ],
        "PDFDocuments": [
            "ru": "PDF Документы",
            "en": "PDF Documents",
            "de": "PDF-Dokumente",
            "tj": "Ҳуҷҷатҳои PDF"
        ],

        // MARK: - Общие
        "All": [
            "ru": "Все",
            "en": "All",
            "de": "Alle",
            "tj": "Ҳама"
        ],
        "NoArticles": [
            "ru": "Нет статей",
            "en": "No articles",
            "de": "Keine Artikel",
            "tj": "Мақола нест"
        ],
        "NoFavorites": [
            "ru": "Нет избранного",
            "en": "No favorites",
            "de": "Keine Favoriten",
            "tj": "Интихобшуда нест"
        ],
        "NoResults": [
            "ru": "Ничего не найдено",
            "en": "Nothing found",
            "de": "Nichts gefunden",
            "tj": "Ҳеҷ чиз ёфт нашуд"
        ],
        "TryAnotherSearchOrCategory": [
            "ru": "Попробуйте другой запрос или категорию",
            "en": "Try another search or category",
            "de": "Versuchen Sie eine andere Suche oder Kategorie",
            "tj": "Ҳарфи дигар ё категорияи дигарро кӯшиш кунед"
        ],

        // MARK: - Поиск
        "Search": [
            "ru": "Поиск",
            "en": "Search",
            "de": "Suche",
            "tj": "Ҷустуҷӯ"
        ],
        "SearchPrompt": [
            "ru": "Искать по статьям или категориям",
            "en": "Search articles or categories",
            "de": "Artikel oder Kategorien suchen",
            "tj": "Ҷустуҷӯи мақолаҳо ё категорияҳо"
        ],

        // MARK: - Статьи
        "RateArticle": [
            "ru": "Оцените статью",
            "en": "Rate this article",
            "de": "Artikel bewerten",
            "tj": "Мақоларо баҳо диҳед"
        ],
        "ShareArticle": [
            "ru": "Поделиться статьёй",
            "en": "Share article",
            "de": "Artikel teilen",
            "tj": "Мақоларо мубодила кунед"
        ],
        "ShareThisArticle": [
            "ru": "Поделиться этой статьёй",
            "en": "Share this article",
            "de": "Diesen Artikel teilen",
            "tj": "Ин мақоларо мубодила кунед"
        ],
        "RelatedArticles": [
            "ru": "Похожие статьи",
            "en": "Related articles",
            "de": "Ähnliche Artikel",
            "tj": "Мақолаҳои монанд"
        ]
    ]

    /// Перевод строки по ключу для текущего языка
    func translate(_ key: String) -> String {
        translations[key]?[selectedLanguage] ?? translations[key]?["en"] ?? key
    }
}
