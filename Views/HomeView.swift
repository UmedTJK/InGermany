//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @State private var articles: [Article] = []
    @State private var categories: [Category] = []

    @ObservedObject var favoritesManager = FavoritesManager()
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    usefulToolsSection
                    recentlyReadSection
                    favoritesSection

                    // 🔹 Каждая категория отдельным блоком
                    categorySection(title: "Финансы", categoryId: "11111111-1111-1111-1111-aaaaaaaaaaaa")
                    categorySection(title: "Работа", categoryId: "22222222-2222-2222-2222-bbbbbbbbbbbb")
                    categorySection(title: "Учёба", categoryId: "33333333-3333-3333-3333-cccccccccccc")
                    categorySection(title: "Бюрократия", categoryId: "44444444-4444-4444-4444-dddddddddddd")
                    categorySection(title: "Жизнь", categoryId: "55555555-5555-5555-5555-eeeeeeeeeeee")

                    allArticlesSection
                }
                .padding(.vertical, 16)
            }
            .navigationTitle(getTranslation(key: "Главная", language: selectedLanguage))
            .task {
                articles = await DataService.shared.loadArticles()
                categories = await DataService.shared.loadCategories()
            }
        }
    }

    // MARK: - Недавно прочитанное
    private var recentlyReadSection: some View {
        let readArticles = articles
            .filter { ReadingHistoryManager.shared.isRead($0.id) }
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }

        return VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Недавно прочитанное", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            if readArticles.isEmpty {
                Text(getTranslation(key: "Нет статей", language: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(readArticles) { article in
                            NavigationLink(
                                destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                            ) {
                                FavoriteCard(article: article, favoritesManager: favoritesManager)
                                    .environmentObject(categoriesStore)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Избранное
    private var favoritesSection: some View {
        let favs = favoritesManager.favoriteArticles(from: articles)
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }

        return VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Избранное", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            if favs.isEmpty {
                Text(getTranslation(key: "Нет статей", language: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(favs) { article in
                            NavigationLink(
                                destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                            ) {
                                FavoriteCard(article: article, favoritesManager: favoritesManager)
                                    .environmentObject(categoriesStore)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Секция категории
    private func categorySection(title: String, categoryId: String) -> some View {
        let filtered = articles
            .filter { $0.categoryId == categoryId }
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }

        return VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: title, language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            if filtered.isEmpty {
                Text(getTranslation(key: "Нет статей", language: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filtered) { article in
                            NavigationLink(
                                destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                            ) {
                                FavoriteCard(article: article, favoritesManager: favoritesManager)
                                    .environmentObject(categoriesStore)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Все статьи
    private var allArticlesSection: some View {
        let sorted = articles
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }

        return VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Все статьи", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            if sorted.isEmpty {
                Text(getTranslation(key: "Нет статей", language: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sorted) { article in
                            NavigationLink(
                                destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )
                            ) {
                                FavoriteCard(article: article, favoritesManager: favoritesManager)
                                    .environmentObject(categoriesStore)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Полезные инструменты
    private var usefulToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Полезные инструменты", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    NavigationLink(destination: MapView()) {
                        ToolButton(icon: "map", title: getTranslation(key: "Карта", language: selectedLanguage))
                    }
                    NavigationLink(destination: PDFViewer(fileName: "sample.pdf")) { // ← здесь укажи реальный PDF
                        ToolButton(icon: "doc.richtext", title: getTranslation(key: "PDF Документы", language: selectedLanguage))
                    }
                    NavigationLink(destination: RandomArticleView(articles: articles, favoritesManager: favoritesManager)) {
                        ToolButton(icon: "shuffle", title: getTranslation(key: "Случайная статья", language: selectedLanguage))
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - UI helper for tools
    private struct ToolButton: View {
        let icon: String
        let title: String

        var body: some View {
            VStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
            }
            .frame(width: 120, height: 100)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - Переводы
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
            "Финансы": ["ru": "Финансы", "en": "Finance", "de": "Finanzen", "tj": "Молия"],
            "Работа": ["ru": "Работа", "en": "Work", "de": "Arbeit", "tj": "Кор"],
            "Учёба": ["ru": "Учёба", "en": "Study", "de": "Studium", "tj": "Таҳсилот"],
            "Бюрократия": ["ru": "Бюрократия", "en": "Bureaucracy", "de": "Bürokratie", "tj": "Бюрократия"],
            "Жизнь": ["ru": "Жизнь", "en": "Life", "de": "Leben", "tj": "Зиндагӣ"],
            "Все статьи": ["ru": "Все статьи", "en": "All Articles", "de": "Alle Artikel", "tj": "Ҳамаи мақолаҳо"],
            "Нет статей": ["ru": "Нет статей", "en": "No articles", "de": "Keine Artikel", "tj": "Мақола нест"],
            "Полезные инструменты": ["ru": "Полезные инструменты", "en": "Useful Tools", "de": "Nützliche Werkzeuge", "tj": "Асбобҳои муфид"],
            "Карта": ["ru": "Карта", "en": "Map", "de": "Karte", "tj": "Харита"],
            "PDF Документы": ["ru": "PDF Документы", "en": "PDF Documents", "de": "PDF Dokumente", "tj": "Ҳуҷҷатҳои PDF"],
            "Случайная статья": ["ru": "Случайная статья", "en": "Random Article", "de": "Zufälliger Artikel", "tj": "Мақолаи тасодуфӣ"],
            "Недавно прочитанное": ["ru": "Недавно прочитанное", "en": "Recently Read", "de": "Zuletzt gelesen", "tj": "Мақолаҳои охирин"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"]
        ]
        return translations[key]?[language] ?? key
    }
}

#Preview {
    HomeView()
        .environmentObject(CategoriesStore.shared)
}
