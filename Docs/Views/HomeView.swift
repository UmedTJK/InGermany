//
//  HomeView.swift
//  InGermany
//

import SwiftUI


/// The main screen of the app displaying sections like tools, recently read, favorites, categories, and all articles.
struct HomeView: View {
    /// Stores the selected interface language.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    /// Manages the state and data for the home screen.
    @StateObject private var viewModel: HomeViewModel

    // MARK: - Init
    /// Initializes the view with an injected or default `HomeViewModel`.
    init(viewModel: HomeViewModel? = nil) {
        if let vm = viewModel {
            _viewModel = StateObject(wrappedValue: vm)
        } else {
            _viewModel = StateObject(wrappedValue: AppContainer.shared.makeHomeViewModel())
        }
    }

    // MARK: - Body
    /// Builds the main navigation stack with dynamic sections.
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)

                Group {
                    if viewModel.isLoading {
                        ProgressView(t("Загрузка данных..."))
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 28) {
                                UsefulToolsSection(
                                    articles: viewModel.articles,
                                    onRandomArticleSelected: { _ in
                                        viewModel.selectRandomArticle()
                                    }
                                )

                                RecentlyReadSection(
                                    articles: viewModel.articles,
                                    favoritesManager: viewModel.favoritesManager,
                                    readingHistoryManager: viewModel.readingHistoryManager
                                )

                                FavoritesSection(
                                    articles: viewModel.articles,
                                    favoritesManager: viewModel.favoritesManager
                                )

                                ForEach(viewModel.allCategories, id: \.id) { category in
                                    if let categoryArticles = viewModel.articlesByCategory[category.id],
                                       !categoryArticles.isEmpty {
                                        CategorySection(
                                            category: category,
                                            articles: categoryArticles,
                                            favoritesManager: viewModel.favoritesManager,
                                            language: selectedLanguage
                                        )
                                    }
                                }

                                AllArticlesSection(
                                    articles: viewModel.articles,
                                    favoritesManager: viewModel.favoritesManager
                                )
                            }
                            .padding(.vertical)
                        }
                        .refreshable { await viewModel.refreshData() }
                    }
                }
            }
            .navigationTitle(t("Главная"))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $viewModel.isShowingRandomArticle) {
                if let article = viewModel.randomArticle {
                    ArticleDetailView(
                        article: article,
                        allArticles: viewModel.articles
                    )
                }
            }
            .task { await viewModel.loadData() }
        }
    }

    // MARK: - Helpers
    /// Returns a color depending on the current data source.
    private func getDataSourceColor() -> Color {
        switch viewModel.dataSource {
        case "network": return .green
        case "memory_cache": return .blue
        case "local": return .orange
        default: return .gray
        }
    }

    /// Retrieves a localized string for a given key.
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
