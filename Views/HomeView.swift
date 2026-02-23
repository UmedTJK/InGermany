//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    // MARK: - Home layout switch (for incremental redesign)
    private enum HomeLayoutStyle: String, CaseIterable, Identifiable {
        case legacy
        case dashboard

        var id: String { rawValue }

        var title: String {
            switch self {
            case .legacy: return "Legacy"
            case .dashboard: return "Dashboard"
            }
        }
    }

    @AppStorage("homeLayoutStyle") private var homeLayoutStyleRaw: String = HomeLayoutStyle.legacy.rawValue

    private var homeLayoutStyle: HomeLayoutStyle {
        HomeLayoutStyle(rawValue: homeLayoutStyleRaw) ?? .legacy
    }

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var viewModel: HomeViewModel

    private let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    private let makeDataService: () -> DataServiceProtocol
    private let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    private let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel
    private let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView
    private let localizationManager: LocalizationManager

    init(
        viewModelFactory: @escaping () -> HomeViewModel,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol,
        makeArticleRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeArticleDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel,
        makeArticleDetailView: @escaping (Article, [Article]) -> ArticleDetailView,
        localizationManager: LocalizationManager
    ) {
        _viewModel = StateObject(wrappedValue: viewModelFactory())
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
        self.makeArticleRowViewModel = makeArticleRowViewModel
        self.makeArticleDetailViewModel = makeArticleDetailViewModel
        self.makeArticleDetailView = makeArticleDetailView
        self.localizationManager = localizationManager
    }

    /// Для превью и тестов
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makePDFLibraryViewModel = { fatalError("Not implemented") }
        self.makeDataService = { fatalError("Not implemented") }
        self.makeArticleRowViewModel = { _ in fatalError("Not implemented") }
        self.makeArticleDetailViewModel = { _, _ in fatalError("Not implemented") }
        self.makeArticleDetailView = { _, _ in fatalError("Not implemented") }
        self.localizationManager = LocalizationManager()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
#if DEBUG
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
#endif

                if viewModel.isLoading {
                    ProgressView(t("Загрузка данных..."))
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch homeLayoutStyle {
                    case .legacy:
                        HomeLegacyLayout(
                            selectedLanguage: selectedLanguage,
                            viewModel: viewModel,
                            makePDFLibraryViewModel: makePDFLibraryViewModel,
                            makeDataService: makeDataService,
                            makeArticleRowViewModel: makeArticleRowViewModel,
                            makeArticleDetailViewModel: makeArticleDetailViewModel,
                            makeArticleDetailView: makeArticleDetailView,
                            localizationManager: localizationManager
                        )
                    case .dashboard:
                        HomeDashboardLayout(
                            t: t,
                            selectedLanguage: selectedLanguage,
                            viewModel: viewModel,
                            makePDFLibraryViewModel: makePDFLibraryViewModel,
                            makeDataService: makeDataService,
                            makeArticleRowViewModel: makeArticleRowViewModel,
                            makeArticleDetailViewModel: makeArticleDetailViewModel,
                            makeArticleDetailView: makeArticleDetailView,
                            localizationManager: localizationManager
                        )
                    }
                }
            }
            .navigationTitle(t("tab_home"))
            .background(DS.Color.background)
            .navigationDestination(isPresented: $viewModel.isShowingRandomArticle) {
                if let article = viewModel.randomArticle {
                    ArticleDetailView(
                        viewModel: makeArticleDetailViewModel(
                            article,
                            viewModel.articles
                        ),
                        localizationManager: localizationManager,
                        articleRowFactory: makeArticleRowViewModel
                    )
                }
            }
            .task { await viewModel.loadData() }
#if DEBUG
            .toolbar {
                Menu {
                    Picker("Layout", selection: $homeLayoutStyleRaw) {
                        ForEach(HomeLayoutStyle.allCases) { style in
                            Text(style.title).tag(style.rawValue)
                        }
                    }
                } label: {
                    Image(systemName: "rectangle.3.group")
                }
            }
#endif
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
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }

    // MARK: - Legacy layout extracted for incremental redesign
    private struct HomeLegacyLayout: View {
        let selectedLanguage: String
        @ObservedObject var viewModel: HomeViewModel

        let makePDFLibraryViewModel: () -> PDFLibraryViewModel
        let makeDataService: () -> DataServiceProtocol
        let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
        let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel
        let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView
        let localizationManager: LocalizationManager

        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DS.Spacing.section) {
                    VStack(alignment: .leading, spacing: DS.Spacing.section) {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text("Полезные инструменты")
                                .font(.headline)
                            Text("Быстрые действия и важные разделы")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        UsefulToolsSection(
                            articles: viewModel.articles,
                            onRandomArticleSelected: { _ in
                                viewModel.selectRandomArticle()
                            },
                            makePDFLibraryViewModel: makePDFLibraryViewModel,
                            makeDataService: makeDataService
                        )
                    }
                    .padding(DS.Spacing.section)
                    .cardContainer(.standard(useMaterial: true))
                    .cardPressFeedback()

                    Rectangle()
                        .fill(DS.Color.separator.opacity(0.4))
                        .frame(height: 0.5)
                        .padding(.vertical, DS.Spacing.section)

                    RecentlyReadSection(
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager,
                        readingStatsManager: viewModel.readingStatsManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )

                    FavoritesSection(
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )

                    ForEach(viewModel.allCategories, id: \.id) { category in
                        if let categoryArticles = viewModel.articlesByCategory[category.id],
                           !categoryArticles.isEmpty {
                            CategorySection(
                                category: category,
                                articles: categoryArticles,
                                favoritesManager: viewModel.favoritesManager,
                                language: selectedLanguage,
                                makeRowViewModel: makeArticleRowViewModel,
                                makeDetailView: { article, all in
                                    makeArticleDetailView(article, all)
                                }
                            )
                        }
                    }

                    AllArticlesSection(
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )
                }
                .padding(.top, DS.Spacing.section)
                .padding(.horizontal, DS.Spacing.contentInset)
                .padding(.bottom, DS.Spacing.section)
            }
            .scrollIndicators(.hidden)
            .refreshable { await viewModel.refreshData() }
        }

        private func t(_ key: String) -> String {
            localizationManager.getTranslation(key: key, language: selectedLanguage)
        }
    }
}

#Preview {
    let container = AppContainer.previewMock()
    HomeView(
        viewModelFactory: { container.makeHomeViewModel() },
        makePDFLibraryViewModel: container.makePDFLibraryViewModel,
        makeDataService: { container.dataService },
        makeArticleRowViewModel: container.makeArticleRowViewModel,
        makeArticleDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        },
        makeArticleDetailView: { article, all in
            container.makeArticleDetailView(article: article, allArticles: all)
        },
        localizationManager: container.localizationManager
    )
}
