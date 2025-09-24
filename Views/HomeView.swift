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

    @EnvironmentObject private var categoriesStore: CategoriesStore

    @State private var articles: [Article] = []
    @State private var isLoading = true
    @State private var dataSource: String = "unknown"

    @State private var isShowingRandomArticle = false
    @State private var randomArticle: Article?

    private var allCategories: [Category] {
        categoriesStore.categories
    }

    private var articlesByCategory: [String: [Article]] {
        Dictionary(grouping: articles) { $0.categoryId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)

                Group {
                    if isLoading {
                        ProgressView("Загрузка данных...")
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 28) {
                                usefulToolsSection
                                recentlyReadSection
                                favoritesSection

                                ForEach(allCategories, id: \.id) { category in
                                    if let categoryArticles = articlesByCategory[category.id],
                                       !categoryArticles.isEmpty {
                                        categorySection(category: category, articles: categoryArticles)
                                    }
                                }

                                allArticlesSection
                            }
                            .padding(.vertical)
                        }
                        .refreshable {
                            await refreshData()
                        }
                    }
                }
            }
            .navigationTitle(getTranslation(key: "Главная", language: selectedLanguage))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $isShowingRandomArticle) {
                if let randomArticle {
                    ArticleView(
                        article: randomArticle,
                        allArticles: articles,
                        favoritesManager: favoritesManager
                    )
                }
            }
            .task {
                await loadData()
            }
        }
    }

    // MARK: - Data loading

    private func loadData() async {
        articles = await DataService.shared.loadArticles()
        let sources = await DataService.shared.getLastDataSource()
        dataSource = sources["articles"] ?? "unknown"
        isLoading = false
    }

    private func refreshData() async {
        isLoading = true
        await DataService.shared.refreshData()
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

    // MARK: - Полезные инструменты

    private var usefulToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Полезные инструменты", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    NavigationLink(destination: MapView()) {
                        ToolCard(
                            title: getTranslation(key: "Карта", language: selectedLanguage),
                            systemImage: "map",
                            color: .blue
                        )
                    }

                    NavigationLink(destination: PDFViewer(fileName: "sample")) {
                        ToolCard(
                            title: getTranslation(key: "PDF Документы", language: selectedLanguage),
                            systemImage: "doc.richtext",
                            color: .green
                        )
                    }

                    Button {
                        if let random = articles.randomElement() {
                            randomArticle = random
                            isShowingRandomArticle = true
                        }
                    } label: {
                        ToolCard(
                            title: getTranslation(key: "Случайная статья", language: selectedLanguage),
                            systemImage: "shuffle",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Недавно прочитанное

    // MARK: - Недавно прочитанное
    private var recentlyReadSection: some View {
        let recentlyRead = readingHistoryManager.recentlyReadArticles(from: articles)

        return Group {
            if !recentlyRead.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(getTranslation(key: "Недавно прочитанное", language: selectedLanguage))
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recentlyRead) { article in
                                NavigationLink(destination: ArticleView(
                                    article: article,
                                    allArticles: articles,
                                    favoritesManager: favoritesManager
                                )) {
                                    RecentArticleCard(article: article) // ✅ только article
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Избранное

    // MARK: - Избранное
    // MARK: - Избранное
    private var favoritesSection: some View {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)

        return Group {
            if !favoriteArticles.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(getTranslation(key: "Избранное", language: selectedLanguage))
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(favoriteArticles) { article in
                                NavigationLink {
                                    ArticleView(
                                        article: article,
                                        allArticles: articles,
                                        favoritesManager: favoritesManager
                                    )
                                } label: {
                                    FavoriteCard(article: article) // ✅ без favoritesManager
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }



    // MARK: - Категории

    private func categorySection(category: Category, articles: [Article]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles.prefix(10)) { article in
                        NavigationLink {
                            ArticleView(
                                article: article,
                                allArticles: self.articles,
                                favoritesManager: favoritesManager
                            )
                        } label: {
                            ArticleCompactCard(article: article)   // ✅ только article
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Все статьи

    private var allArticlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getTranslation(key: "Все статьи", language: selectedLanguage))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles) { article in
                        NavigationLink {
                            ArticleView(
                                article: article,
                                allArticles: articles,
                                favoritesManager: favoritesManager
                            )
                        } label: {
                            ArticleCompactCard(article: article)   // ✅ только article
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Локализация заголовков

    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Саҳифаи асосӣ"],
            "Полезные инструменты": ["ru": "Полезные инструменты", "en": "Useful tools", "de": "Nützliche Werkzeuge", "tj": "Асбобҳои муфид"],
            "Карта": ["ru": "Карта", "en": "Map", "de": "Karte", "tj": "Харита"],
            "PDF Документы": ["ru": "PDF Документы", "en": "PDF Documents", "de": "PDF-Dokumente", "tj": "Ҳуҷҷатҳои PDF"],
            "Случайная статья": ["ru": "Случайная статья", "en": "Random article", "de": "Zufälliger Artikel", "tj": "Мақолаи тасодуфӣ"],
            "Недавно прочитанное": ["ru": "Недавно прочитанное", "en": "Recently read", "de": "Kürzlich gelesen", "tj": "Мақолаҳои охир хондашуда"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Все статьи": ["ru": "Все статьи", "en": "All articles", "de": "Alle Artikel", "tj": "Ҳамаи мақолаҳо"]
        ]
        return translations[key]?[language] ?? key
    }
}
