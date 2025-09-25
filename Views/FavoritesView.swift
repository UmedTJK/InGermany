//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @State private var searchText = ""
    @State private var articles: [Article] = []
    @State private var isLoading = true
    @State private var dataSource: String = "unknown"
    
    private var filteredFavoriteArticles: [Article] {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)
        if searchText.isEmpty {
            return favoriteArticles
        } else {
            return favoriteArticles.filter {
                $0.localizedTitle(for: selectedLanguage).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
                
                if isLoading {
                    ProgressView("Загрузка избранного...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if filteredFavoriteArticles.isEmpty {
                        Text(getTranslation(key: "Нет избранных статей", language: selectedLanguage))
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        favoritesList
                    }
                }
            }
            .navigationTitle(getTranslation(key: "Избранное", language: selectedLanguage))
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: getTranslation(key: "Поиск в избранном", language: selectedLanguage))
            .task {
                await loadData()
            }
        }
    }
    
    // MARK: - Favorites List
    private var favoritesList: some View {
        List(filteredFavoriteArticles) { article in
            NavigationLink {
                ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow(article: article) // ✅ без favoritesManager
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Data loading
    private func loadData() async {
        articles = await DataService.shared.loadArticles()
        let sources = await DataService.shared.getLastDataSource()
        dataSource = sources["articles"] ?? "unknown"
        isLoading = false
    }
    
    private func getDataSourceColor() -> Color {
        switch dataSource {
        case "network": return .green
        case "memory_cache": return .blue
        case "local": return .orange
        default: return .gray
        }
    }
    
    // MARK: - Translation
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Избранное": [
                "ru": "Избранное",
                "en": "Favorites",
                "de": "Favoriten",
                "tj": "Интихобшуда"
            ],
            "Нет избранных статей": [
                "ru": "Нет избранных статей",
                "en": "No favorite articles",
                "de": "Keine Favoriten",
                "tj": "Мақолаҳои интихобшуда нест"
            ],
            "Поиск в избранном": [
                "ru": "Поиск в избранном",
                "en": "Search favorites",
                "de": "Favoriten durchsuchen",
                "tj": "Ҷустуҷӯ дар интихобшудаҳо"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
