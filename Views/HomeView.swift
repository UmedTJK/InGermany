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
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
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
                    
                    // 🔹 Недавно прочитанные статьи
                    recentlyReadSection
                    
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
                        Text(getTranslation(key: "Карта локаций", language: selectedLanguage))
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
                        Text(getTranslation(key: "Случайная статья", language: selectedLanguage))
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
            Text(getTranslation(key: "Полезное", language: selectedLanguage))
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
        }
    }
    
    private var recentlyReadSection: some View {
        let recentArticles = readingHistoryManager.recentlyReadArticles(from: articles, limit: 5)
        return Group {
            if !recentArticles.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recentArticles) { article in
                                NavigationLink(
                                    destination: ArticleView(
                                        article: article,
                                        allArticles: articles,
                                        favoritesManager: favoritesManager
                                    )
                                ) {
                                    RecentArticleCard(
                                        article: article,
                                        favoritesManager: favoritesManager,
                                        lastReadDate: readingHistoryManager.lastReadDate(for: article.id)
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
                        Text(getTranslation(key: "Недавно прочитанное", language: selectedLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(recentArticles.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
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
                        
                        NavigationLink(getTranslation(key: "Все", language: selectedLanguage)) {
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
                
                NavigationLink(getTranslation(key: "Все", language: selectedLanguage)) {
                    ArticlesByCategoryView(
                        category: category,
                        articles: self.articles,
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
                        ArticleRowWithReadingInfo(
                            article: article,
                            favoritesManager: favoritesManager,
                            isRead: readingHistoryManager.isRead(article.id)
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
            "Карта локаций": ["ru": "Карта локаций", "en": "Location Map", "de": "Standortkarte", "tj": "Харитаи ҷойҳо"],
            "Случайная статья": ["ru": "Случайная статья", "en": "Random Article", "de": "Zufälliger Artikel", "tj": "Мақолаи тасодуфӣ"],
            "Полезное": ["ru": "Полезное", "en": "Useful", "de": "Nützliches", "tj": "Муфид"],
            "Недавно прочитанное": ["ru": "Недавно прочитанное", "en": "Recently Read", "de": "Kürzlich gelesen", "tj": "Ба наздикӣ хондашуда"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Все статьи": ["ru": "Все статьи", "en": "All Articles", "de": "Alle Artikel", "tj": "Ҳамаи мақолаҳо"],
            "Все": ["ru": "Все", "en": "All", "de": "Alle", "tj": "Ҳама"]
        ]
        return translations[key]?[language] ?? key
    }
}

// MARK: - Новые компоненты

// Карточка для недавно прочитанных статей
struct RecentArticleCard: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let lastReadDate: Date?
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    private var timeAgoText: String {
        guard let lastReadDate = lastReadDate else { return "" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        switch selectedLanguage {
        case "en":
            formatter.locale = Locale(identifier: "en_US")
        case "de":
            formatter.locale = Locale(identifier: "de_DE")
        case "tj":
            formatter.locale = Locale(identifier: "ru_RU") // Используем русский как базу
        default:
            formatter.locale = Locale(identifier: "ru_RU")
        }
        
        return formatter.localizedString(for: lastReadDate, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Верхняя часть с иконкой "прочитано" и избранным
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
                
                Spacer()
                
                // Иконка избранного
                Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(favoritesManager.isFavorite(article: article) ? .yellow : .gray.opacity(0.6))
            }
            
            // Заголовок статьи
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Время чтения статьи и когда была прочитана
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if !timeAgoText.isEmpty {
                    Text(timeAgoText)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
        }
        .padding(16)
        .frame(width: 170, height: 140)
        .cardStyle()
    }
}

// Улучшенный ArticleRow с информацией о чтении
struct ArticleRowWithReadingInfo: View {
    let article: Article
    let favoritesManager: FavoritesManager
    let isRead: Bool
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Миниатюрное изображение (временно — логотип)
            ZStack(alignment: .topTrailing) {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
                
                // Индикатор "прочитано"
                if isRead {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Заголовок статьи
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Категория и время чтения
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text(
                            CategoryManager.shared
                                .category(for: article.categoryId)?
                                .localizedName(for: selectedLanguage)
                            ?? "Без категории"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Время чтения
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(article.formattedReadingTime(for: selectedLanguage))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Индикатор "Избранное"
            Image(systemName: favoritesManager.isFavorite(article: article) ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
    }
}

// Новая карточка для статей категорий (обновленная)
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
            
            Spacer()
            
            // Время чтения
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text(article.formattedReadingTime(for: selectedLanguage))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
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
