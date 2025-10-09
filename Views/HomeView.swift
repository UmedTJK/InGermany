//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var appContainer: AppContainer

    init() {
        _viewModel = StateObject(wrappedValue: AppContainer.shared.makeHomeViewModel())
    }

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)

                if viewModel.isLoading {
                    ProgressView(t("Загрузка данных..."))
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                readingStatsManager: viewModel.readingStatsManager
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
            .navigationTitle(t("Главная"))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $viewModel.isShowingRandomArticle) {
                if let article = viewModel.randomArticle {
                    ArticleDetailView(
                        article: article,
                        allArticles: viewModel.articles,
                        appContainer: appContainer
                    )
                }
            }
            .task { await viewModel.loadData() }
        }
    }

    private func getDataSourceColor() -> Color {
        switch viewModel.dataSource {
        case "network": return .green
        case "memory_cache": return .blue
        case "local": return .orange
        default: return .gray
        }
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppContainer.previewMock())
}
