//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var selectedCategory: String? = nil
    @State private var searchText: String = ""
    
    // Вычисляемое свойство для отфильтрованных избранных статей
    private var filteredFavoriteArticles: [Article] {
        let favorites = favoritesManager.favoriteArticles(from: articles)
        
        // Фильтрация по категории
        var filtered = favorites
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.categoryId == selectedCategory }
        }
        
        // Фильтрация по поиску
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                let title = article.title[selectedLanguage] ?? article.title["ru"] ?? ""
                return title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    // Получаем уникальные категории из избранного
    private var favoriteCategories: [Category] {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)
        let categoryIDs = Set(favoriteArticles.map { $0.categoryId })
        return CategoryManager.shared.allCategories().filter { categoryIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Панель фильтров категорий (только если есть избранное)
                if !favoriteCategories.isEmpty && !filteredFavoriteArticles.isEmpty {
                    categoryFilterScrollView
                }
                
                // Список избранного
                if filteredFavoriteArticles.isEmpty {
                    EmptyFavoritesView(
                        hasFilters: selectedCategory != nil || !searchText.isEmpty,
                        selectedLanguage: selectedLanguage,
                        getTranslation: getTranslation
                    )
                } else {
                    favoritesList
                }
            }
            .navigationTitle(navigationTitle)
        }
        .searchable(text: $searchText, prompt: getTranslation(key: "Поиск в избранном", language: selectedLanguage))
    }
    
    private var navigationTitle: String {
        let baseTitle = getTranslation(key: "Избранное", language: selectedLanguage)
        return "\(baseTitle) (\(filteredFavoriteArticles.count))"
    }
    
    // Выносим сложные view в отдельные вычисляемые свойства
    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Кнопка "Все категории"
                CategoryFilterButton(
                    title: getTranslation(key: "Все", language: selectedLanguage),
                    isSelected: selectedCategory == nil,
                    systemImage: "star.fill"
                ) {
                    selectedCategory = nil
                }
                
                // Кнопки для каждой категории
                ForEach(favoriteCategories) { category in
                    CategoryFilterButton(
                        title: category.localizedName(for: selectedLanguage),
                        isSelected: selectedCategory == category.id,
                        systemImage: category.icon
                    ) {
                        selectedCategory = category.id
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
    
    private var favoritesList: some View {
        List(filteredFavoriteArticles) { article in
            NavigationLink {
                ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow(
                    article: article,
                    favoritesManager: favoritesManager
                )
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // Переименовали метод чтобы избежать конфликта с Foundation
    private func getTranslation(key: String, language: String) -> String {
        // Простая локализация для стандартных фраз
        let translations: [String: [String: String]] = [
            "Все": ["ru": "Все", "en": "All", "de": "Alle", "tj": "Ҳама"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Нет избранного": ["ru": "Нет избранного", "en": "No favorites", "de": "Keine Favoriten", "tj": "Интихобшуда нест"],
            "Попробуйте другую категорию": ["ru": "Попробуйте выбрать другую категорию", "en": "Try selecting another category", "de": "Versuchen Sie eine andere Kategorie", "tj": "Категорияи дигарро интихоб кунед"],
            "Поиск в избранном": ["ru": "Поиск в избранном", "en": "Search favorites", "de": "Favoriten durchsuchen", "tj": "Дар интихобшуда ҷустуҷӯ"],
            "Ничего не найдено": ["ru": "Ничего не найдено", "en": "Nothing found", "de": "Nichts gefunden", "tj": "Ҳеҷ чиз ёфт нашуд"],
            "Попробуйте другой запрос или категорию": ["ru": "Попробуйте другой запрос или категорию", "en": "Try another search or category", "de": "Versuchen Sie eine andere Suche oder Kategorie", "tj": "Ҳарфи дигар ё категорияи дигарро кӯшиш кунед"]
        ]
        
        return translations[key]?[language] ?? key
    }
}

// Компонент кнопки фильтра категории
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Вью для пустого состояния
struct EmptyFavoritesView: View {
    let hasFilters: Bool
    let selectedLanguage: String
    let getTranslation: (String, String) -> String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasFilters ? "magnifyingglass" : "star")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .opacity(0.5)
            
            Text(hasFilters ?
                 getTranslation("Ничего не найдено", selectedLanguage) :
                 getTranslation("Нет избранного", selectedLanguage)
            )
            .font(.headline)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            
            if hasFilters {
                Text(getTranslation("Попробуйте другой запрос или категорию", selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.bottom, 100)
    }
}

#Preview {
    FavoritesView(
        favoritesManager: FavoritesManager(),
        articles: [Article.sampleArticle]
    )
}
