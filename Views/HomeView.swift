//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
    @StateObject private var categoriesRepository = CategoriesRepository.shared

    @State private var articles: [Article] = []
    @State private var isLoading = true
    @State private var dataSource: String = "unknown"

    @State private var isShowingRandomArticle = false
    @State private var randomArticle: Article?

    private var allCategories: [Category] {
        categoriesRepository.allCategories()
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
                        ProgressView(t("Загрузка данных..."))
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 28) {
                                UsefulToolsSection(
                                    articles: articles,
                                    onRandomArticleSelected: { article in
                                        randomArticle = article
                                        isShowingRandomArticle = true
                                    }
                                )

                                RecentlyReadSection(
                                    articles: articles,
                                    favoritesManager: favoritesManager,
                                    readingHistoryManager: readingHistoryManager
                                )

                                FavoritesSection(
                                    articles: articles,
                                    favoritesManager: favoritesManager
                                )

                                ForEach(allCategories, id: \.id) { category in
                                    if let categoryArticles = articlesByCategory[category.id],
                                       !categoryArticles.isEmpty {
                                        CategorySection(
                                            category: category,
                                            articles: categoryArticles,
                                            favoritesManager: favoritesManager,
                                            language: selectedLanguage
                                        )
                                    }
                                }

                                AllArticlesSection(
                                    articles: articles,
                                    favoritesManager: favoritesManager
                                )
                            }
                            .padding(.vertical)
                        }
                        .refreshable { await refreshData() }
                    }
                }
            }
            .navigationTitle(t("Главная"))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $isShowingRandomArticle) {
                if let randomArticle {
                    ArticleDetailView(
                        article: randomArticle,
                        allArticles: articles,
                        favoritesManager: favoritesManager
                    )
                }
            }
            .task { await loadData() }
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

    // MARK: - Localization

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
