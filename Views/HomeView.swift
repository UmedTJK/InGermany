//
//  HomeView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    
    // Состояние для управления навигацией к случайной статье
    @State private var isShowingRandomArticle = false
    @State private var randomArticle: Article?
    
    // Получаем все категории
    private var allCategories: [Category] {
        CategoryManager.shared.allCategories()
    }
    
    // Группируем статьи по категориям
    private var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles) { $0.categoryId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // 🔹 Раздел с картой и случайной статьей
                    usefulToolsSection
                    
                    // 🔹 Избранные статьи - горизонтальный скролл карточек
                    favoritesSection
                    
                    // 🔹 Категории с горизонтальными скроллами
                    ForEach(allCategories, id: \.id) { category in
                        if let categoryArticles = articlesByCategory[category.id], !categoryArticles.isEmpty {
                            categorySection(category: category, articles: categoryArticles)
                        }
                    }
                    
                    // 🔹 Все статьи - обычный список
                    allArticlesSection
                }
                .padding(.vertical)
            }
            .navigationTitle(getTranslation(key: "Главная", language: selectedLanguage))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $isShowingRandomArticle) {
                Group {
                    if let randomArticle {
                        ArticleView(
                            article: randomArticle,
                            allArticles: articles,
                            favoritesManager: favoritesManager
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var usefulToolsSection: some View {
        Section {
            VStack(spacing: 12) {
                // Карта локаций
                NavigationLink {
                    MapView()
                } label: {
                    HStack {
                        Image(systemName: "map")
                            .foregroundColor(.blue)
                        Text("Карта локаций")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                }
                
                // Кнопка "Случайная статья"
                Button(action: {
                    randomArticle = articles.randomElement()
                    isShowingRandomArticle = true
                }) {
                    HStack {
                        Image(systemName: "dice.fill")
                            .foregroundColor(.green)
                        Text("Случайная статья")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                }
            }
            .padding(.horizontal)
        } header: {
            Text("Полезное")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
        }
    }
    
    private var favoritesSection: some View {
        let favorites = favoritesManager.favoriteArticles(from: articles)
        return Group {
            if !favorites.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(favorites) { article in
                                NavigationLink(
                                    destination: ArticleView(
                                        article: article,
                                        allArticles: articles,
                                        favoritesManager: favoritesManager
                                    )
                                ) {
                                    FavoriteCard(
                                        article: article,
                                        favoritesManager: favoritesManager
                                    )
                                }
                                .buttonStyle(AppleCardButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Text("\(getTranslation(key: "Избранное", language: selectedLanguage)) (\(favorites.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        NavigationLink("Все") {
                            FavoritesView(
                                favoritesManager: favoritesManager,
                                articles: articles
                            )
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func categorySection(category: Category, articles: [Article]) -> some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(articles) { article in
                        NavigationLink(
                            destination: ArticleView(
                                article: article,
                                allArticles: self.articles,
                                favoritesManager: favoritesManager
                            )
                        ) {
                            CategoryArticleCard(
                                article: article,
                                category: category,
                                favoritesManager: favoritesManager
                            )
                        }
                        .buttonStyle(AppleCardButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        } header: {
            HStack {
                Label {
                    Text(category.localizedName(for: selectedLanguage))
                        .font(.headline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: category.icon)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("\(articles.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // В HomeView.swift в методе categorySection:
                NavigationLink("Все") {
                    ArticlesByCategoryView(
                        category: category,
                        articles: self.articles, // Передаем все статьи
                        favoritesManager: favoritesManager
                    )
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
    }
    
    private var allArticlesSection: some View {
        Section {
            LazyVStack(spacing: 12) {
                ForEach(articles) { article in
                    NavigationLink(
                        destination: ArticleView(
                            article: article,
                            allArticles: articles,
                            favoritesManager: favoritesManager
                        )
                    ) {
                        ArticleRow(
                            article: article,
                            favoritesManager: favoritesManager
                        )
                    }
                }
            }
            .padding(.horizontal)
        } header: {
            Text("\(getTranslation(key: "Все статьи", language: selectedLanguage)) (\(articles.count))")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Все статьи": ["ru": "Все статьи", "en": "All Articles", "de": "Alle Artikel", "tj": "Ҳамаи мақолаҳо"],
            "Полезное": ["ru": "Полезное", "en": "Useful", "de": "Nützliches", "tj": "Муфид"]
        ]
        return translations[key]?[language] ?? key
    }
}

// Новая карточка для статей категорий
struct CategoryArticleCard: View {
    let article: Article
    let category: Category
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Иконка категории
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Иконка избранного
                Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(favoritesManager.isFavorite(article: article) ? .yellow : .gray.opacity(0.6))
            }
            
            // Заголовок статьи
            Text(article.title[selectedLanguage] ?? article.title["ru"] ?? "")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(width: 150, height: 100)
        .cardStyle()
    }
}

#Preview {
    HomeView(
        favoritesManager: FavoritesManager(),
        articles: DataService.shared.loadArticles()
    )
}
