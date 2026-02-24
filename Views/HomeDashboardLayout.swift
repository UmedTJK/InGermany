//
//  HomeDashboardLayout.swift
//  InGermany
//
//  Created by SUM TJK on 23.02.26.
//

import SwiftUI

struct HomeDashboardLayout: View {
    let t: (String) -> String
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
                    title: t("home_today"),
                    actionTitle: t("home_random_short"),
                    action: { viewModel.selectRandomArticle() }
                )

                if let featured = viewModel.articles.first {
                    NavigationLink {
                        ArticleDetailView(
                            viewModel: makeArticleDetailViewModel(featured, viewModel.articles),
                            localizationManager: localizationManager,
                            articleRowFactory: makeArticleRowViewModel
                        )
                    } label: {
                        ArticleCompactCard(viewModel: makeArticleRowViewModel(featured))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(t("home_no_articles_title"))
                            .font(.headline)
                        Text(t("home_no_articles_subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(DS.Spacing.section)
                    .cardContainer(.standard(useMaterial: true))
                }

                // QUICK ACTIONS
                HomeQuickActionsRow(
                    t: t,
                    onRandom: { viewModel.selectRandomArticle() },
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
                    Text(t("tab_categories"))
                        .font(.headline)

                    Spacer()

                    NavigationLink {
                        HomeDashboardCategoriesOverview(
                            t: t,
                            selectedLanguage: selectedLanguage,
                            viewModel: viewModel,
                            makeArticleRowViewModel: makeArticleRowViewModel,
                            makeArticleDetailView: makeArticleDetailView
                        )
                    } label: {
                        Text(t("common_all"))
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, DS.Spacing.xs)

                let nonEmptyCategories = viewModel.allCategories.filter { category in
                    if let items = viewModel.articlesByCategory[category.id] { return !items.isEmpty }
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

                // ALL ARTICLES (entry)
                NavigationLink {
                    HomeDashboardAllArticlesScreen(
                        t: t,
                        selectedLanguage: selectedLanguage,
                        viewModel: viewModel,
                        makeArticleRowViewModel: makeArticleRowViewModel,
                        makeArticleDetailViewModel: makeArticleDetailViewModel
                    )
                } label: {
                    HStack(spacing: DS.Spacing.s) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(t("section_all_articles"))
                                .font(.headline)
                            Text(t("home_full_list"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(DS.Spacing.section)
                    .cardContainer(.standard(useMaterial: true))
                    .cardPressFeedback()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, DS.Spacing.section)
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.section)
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.refreshData() }
    }
}

// MARK: - Components

private struct HomeQuickActionsRow: View {
    let t: (String) -> String
    let onRandom: () -> Void
    let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    let makeDataService: () -> DataServiceProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(t("home_quick_actions_title"))
                .font(.headline)
            Text(t("home_quick_actions_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.s) {
                    Button(action: onRandom) {
                        actionCard(
                            title: t("home_random_short"),
                            subtitle: t("home_article"),
                            systemImage: "dice"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PDFLibraryView(viewModel: makePDFLibraryViewModel())
                    } label: {
                        actionCard(
                            title: "PDF",
                            subtitle: t("home_pdf_library"),
                            systemImage: "doc.richtext"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        MapView(dataService: makeDataService())
                    } label: {
                        actionCard(
                            title: t("tool_map"),
                            subtitle: t("home_places"),
                            systemImage: "map"
                        )
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
                Text(title).font(.headline)
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
    let t: (String) -> String
    let selectedLanguage: String
    @ObservedObject var viewModel: HomeViewModel

    let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DS.Spacing.section) {
                let nonEmptyCategories = viewModel.allCategories.filter { category in
                    if let items = viewModel.articlesByCategory[category.id] { return !items.isEmpty }
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
        .navigationTitle(t("tab_categories"))
        .background(DS.Color.background)
    }
}

private struct HomeDashboardAllArticlesScreen: View {
    let t: (String) -> String
    let selectedLanguage: String
    @ObservedObject var viewModel: HomeViewModel

    let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    @State private var searchQuery: String = ""

    private var filteredArticles: [Article] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return viewModel.articles }
        let q = trimmed.lowercased()

        return viewModel.articles.filter { article in
            // Search through all localized titles, plus prefer the selected language when available.
            let titles = article.title
            if let preferred = titles[selectedLanguage]?.lowercased(), preferred.contains(q) { return true }
            return titles.values.contains { $0.lowercased().contains(q) }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DS.Spacing.section) {
                if filteredArticles.isEmpty {
                    emptyState
                } else {
                    AllArticlesSection(
                        articles: filteredArticles,
                        favoritesManager: viewModel.favoritesManager,
                        makeRowViewModel: makeArticleRowViewModel,
                        makeDetailViewModel: { article, all in
                            makeArticleDetailViewModel(article, all)
                        }
                    )
                }
            }
            .padding(.top, DS.Spacing.section)
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.section)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(t("section_all_articles"))
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(t("search_placeholder")))
        .background(DS.Color.background)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack(alignment: .center, spacing: DS.Spacing.m) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(t("search_no_results_title"))
                        .font(.headline)

                    Text(t("search_no_results_desc"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Button {
                searchQuery = ""
            } label: {
                Text(t("common_reset"))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.s)
            }
            .buttonStyle(.bordered)
        }
        .padding(DS.Spacing.section)
        .cardContainer(.standard(useMaterial: true))
    }
}
