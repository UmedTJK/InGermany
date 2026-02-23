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

    // MARK: - Dashboard layout skeleton (WIP)
    private struct HomeDashboardLayout: View {
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
                VStack(alignment: .leading, spacing: DS.Spacing.section) {
                    // HERO
                    SectionHeader(
                        title: "Сегодня",
                        actionTitle: "Случайная",
                        action: {
                            viewModel.selectRandomArticle()
                        }
                    )

                    if let featured = viewModel.articles.first {
                        NavigationLink {
                            ArticleDetailView(
                                viewModel: makeArticleDetailViewModel(featured, viewModel.articles),
                                localizationManager: localizationManager,
                                articleRowFactory: makeArticleRowViewModel
                            )
                        } label: {
                            ArticleCompactCard(
                                viewModel: makeArticleRowViewModel(featured)
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    } else {
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text("Пока нет статей")
                                .font(.headline)
                            Text("Данные загружаются или пока недоступны.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(DS.Spacing.section)
                        .cardContainer(.standard(useMaterial: true))
                    }

                    // QUICK ACTIONS
                    HomeQuickActionsRow(
                        onRandom: {
                            viewModel.selectRandomArticle()
                        },
                        makePDFLibraryViewModel: makePDFLibraryViewModel,
                        makeDataService: makeDataService
                    )

                    // CONTINUE READING
                    RecentlyReadSection(
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager,
                        readingStatsManager: viewModel.readingStatsManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )

                    // FAVORITES
                    FavoritesSection(
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )

                    // CATEGORIES (preview)
                    HStack(alignment: .firstTextBaseline) {
                        Text("Категории")
                            .font(.headline)

                        Spacer()

                        NavigationLink {
                            HomeDashboardCategoriesOverview(
                                selectedLanguage: selectedLanguage,
                                viewModel: viewModel,
                                makeArticleRowViewModel: makeArticleRowViewModel,
                                makeArticleDetailView: makeArticleDetailView
                            )
                        } label: {
                            Text("Все")
                                .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, DS.Spacing.xs)

                    let nonEmptyCategories = viewModel.allCategories.filter { category in
                        if let items = viewModel.articlesByCategory[category.id] {
                            return !items.isEmpty
                        }
                        return false
                    }

                    ForEach(nonEmptyCategories.prefix(3), id: \.id) { category in
                        if let items = viewModel.articlesByCategory[category.id], !items.isEmpty {
                            CategorySection(
                                category: category,
                                articles: Array(items.prefix(10)),
                                favoritesManager: viewModel.favoritesManager,
                                language: selectedLanguage,
                                makeRowViewModel: makeArticleRowViewModel,
                                makeDetailView: { article, all in
                                    makeArticleDetailView(article, all)
                                }
                            )
                        }
                    }
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

        private struct HomeQuickActionsRow: View {
            let onRandom: () -> Void
            let makePDFLibraryViewModel: () -> PDFLibraryViewModel
            let makeDataService: () -> DataServiceProtocol

            var body: some View {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Быстрые действия")
                        .font(.headline)
                    Text("Открой нужный раздел в один тап")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Spacing.s) {
                            Button(action: onRandom) {
                                actionCard(title: "Случайная", subtitle: "Статья", systemImage: "dice")
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                PDFLibraryView(viewModel: makePDFLibraryViewModel())
                            } label: {
                                actionCard(title: "PDF", subtitle: "Библиотека", systemImage: "doc.richtext")
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                MapView(dataService: makeDataService())
                            } label: {
                                actionCard(title: "Карта", subtitle: "Места", systemImage: "map")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, DS.Spacing.xs)
                    }
                }
                .padding(DS.Spacing.section)
                .cardContainer(.standard(useMaterial: true))
                .cardPressFeedback()
            }

            @ViewBuilder
            private func actionCard(title: String, subtitle: String, systemImage: String) -> some View {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Image(systemName: systemImage)
                        .font(.title3)
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 180, alignment: .leading)
                .padding(DS.Spacing.m)
                .cardContainer(.standard(useMaterial: false))
            }
        }

        private struct HomeDashboardCategoriesOverview: View {
            let selectedLanguage: String
            @ObservedObject var viewModel: HomeViewModel

            let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
            let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView

            var body: some View {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DS.Spacing.section) {
                        let nonEmptyCategories = viewModel.allCategories.filter { category in
                            if let items = viewModel.articlesByCategory[category.id] {
                                return !items.isEmpty
                            }
                            return false
                        }

                        ForEach(nonEmptyCategories, id: \.id) { category in
                            if let items = viewModel.articlesByCategory[category.id], !items.isEmpty {
                                CategorySection(
                                    category: category,
                                    articles: items,
                                    favoritesManager: viewModel.favoritesManager,
                                    language: selectedLanguage,
                                    makeRowViewModel: makeArticleRowViewModel,
                                    makeDetailView: { article, all in
                                        makeArticleDetailView(article, all)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.top, DS.Spacing.section)
                    .padding(.horizontal, DS.Spacing.contentInset)
                    .padding(.bottom, DS.Spacing.section)
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Категории")
                .background(DS.Color.background)
            }
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
