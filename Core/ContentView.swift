//
//  ContentView.swift
//  InGermany
//

import SwiftUI

/// Обёртка для ленивой инициализации во вкладках
struct LazyView<Content: View>: View {
    private let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        build()
    }
}

struct ContentView: View {

    // Factories injected from composition root (no AppContainer in UI layer)
    let makeHomeViewModel: () -> HomeViewModel
    let makeCategoriesViewModel: () -> CategoriesViewModel
    let makeSearchViewModel: () -> SearchViewModel
    let makeFavoritesViewModel: () -> FavoritesViewModel
    let makeSettingsViewModel: () -> SettingsViewModel
    let makeAboutViewModel: () -> AboutViewModel
    let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    let makeDataService: () -> DataServiceProtocol
    let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel
    let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView
    let dumpNetworkMetrics: @Sendable (_ reset: Bool) async -> String

    @EnvironmentObject var localizationManager: LocalizationManager

    // ✅ Источник темы — SettingsManager
    @EnvironmentObject var settingsManager: SettingsManager

    @State private var selectedTab: Int = 0

    // MARK: - Init
    init(
        makeHomeViewModel: @escaping () -> HomeViewModel,
        makeCategoriesViewModel: @escaping () -> CategoriesViewModel,
        makeSearchViewModel: @escaping () -> SearchViewModel,
        makeFavoritesViewModel: @escaping () -> FavoritesViewModel,
        makeSettingsViewModel: @escaping () -> SettingsViewModel,
        makeAboutViewModel: @escaping () -> AboutViewModel,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol,
        makeArticleRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeArticleDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel,
        makeArticleDetailView: @escaping (Article, [Article]) -> ArticleDetailView,
        dumpNetworkMetrics: @escaping @Sendable (_ reset: Bool) async -> String = { _ in "" }
    ) {
        self.makeHomeViewModel = makeHomeViewModel
        self.makeCategoriesViewModel = makeCategoriesViewModel
        self.makeSearchViewModel = makeSearchViewModel
        self.makeFavoritesViewModel = makeFavoritesViewModel
        self.makeSettingsViewModel = makeSettingsViewModel
        self.makeAboutViewModel = makeAboutViewModel
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
        self.makeArticleRowViewModel = makeArticleRowViewModel
        self.makeArticleDetailViewModel = makeArticleDetailViewModel
        self.makeArticleDetailView = makeArticleDetailView
        self.dumpNetworkMetrics = dumpNetworkMetrics
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            LazyView {
                HomeView(
                    viewModelFactory: makeHomeViewModel,
                    makePDFLibraryViewModel: makePDFLibraryViewModel,
                    makeDataService: makeDataService,
                    makeArticleRowViewModel: makeArticleRowViewModel,
                    makeArticleDetailViewModel: makeArticleDetailViewModel,
                    makeArticleDetailView: makeArticleDetailView,
                    localizationManager: localizationManager
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_home"),
                    systemImage: "house.fill"
                )
            }
            .tag(0)

            LazyView {
                CategoriesView(
                    viewModel: makeCategoriesViewModel(),
                    makeRowViewModel: makeArticleRowViewModel,
                    makeDetailViewModel: makeArticleDetailViewModel
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_categories"),
                    systemImage: "square.grid.2x2"
                )
            }
            .tag(1)

            LazyView {
                SearchView(
                    viewModel: makeSearchViewModel(),
                    makeRowViewModel: makeArticleRowViewModel,
                    makeDetailViewModel: makeArticleDetailViewModel
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_search"),
                    systemImage: "magnifyingglass"
                )
            }
            .tag(2)

            LazyView {
                FavoritesView(
                    viewModel: makeFavoritesViewModel(),
                    makeRowViewModel: makeArticleRowViewModel,
                    makeDetailViewModel: makeArticleDetailViewModel
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_favorites"),
                    systemImage: "heart.fill"
                )
            }
            .tag(3)

            LazyView {
                SettingsView(
                    viewModel: makeSettingsViewModel(),
                    makeAboutViewModel: makeAboutViewModel,
                    dumpNetworkMetrics: dumpNetworkMetrics
                )
            }
            .tabItem {
                Label(
                    localizationManager.t("tab_settings"),
                    systemImage: "gearshape.fill"
                )
            }
            .tag(4)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)

        // 🌙 Реактивная тема — корректно
        .environment(
            \.colorScheme,
            settingsManager.isDarkMode ? .dark : .light
        )
    }
}

#Preview {
    let container = AppContainer.previewMock()
    ContentView(
        makeHomeViewModel: container.makeHomeViewModel,
        makeCategoriesViewModel: container.makeCategoriesViewModel,
        makeSearchViewModel: container.makeSearchViewModel,
        makeFavoritesViewModel: container.makeFavoritesViewModel,
        makeSettingsViewModel: container.makeSettingsViewModel,
        makeAboutViewModel: container.makeAboutViewModel,
        makePDFLibraryViewModel: container.makePDFLibraryViewModel,
        makeDataService: { container.dataService },
        makeArticleRowViewModel: container.makeArticleRowViewModel,
        makeArticleDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        },
        makeArticleDetailView: { article, all in
            container.makeArticleDetailView(article: article, allArticles: all)
        },
        dumpNetworkMetrics: { reset in
            await container.dumpNetworkMetrics(reset: reset)
        }
    )
    .appEnvironment(using: container)
}
