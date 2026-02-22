//
//  SearchView.swift
//  InGermany
//

import SwiftUI

/// Provides a search interface for articles and categories with tag filtering and navigation.
struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var didInitialLoad: Bool = false
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    /// Initializes the view with injected viewModel and factory closures
    init(
        viewModel: SearchViewModel,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
    }

    /// Builds the main search interface with tag filter, searchable list of articles, and navigation to detail view.
    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.m) {
                if !viewModel.allTags.isEmpty {
                    TagFilterView(tags: viewModel.allTags) { tag in
                        viewModel.selectedTag = (viewModel.selectedTag == tag) ? nil : tag
                    }
                    .padding(.horizontal, DS.Spacing.contentInset)
                }

                if viewModel.filteredArticles.isEmpty {
                    ContentUnavailableView(
                        localizationManager.t("search_no_results_title"),
                        systemImage: "doc.text.magnifyingglass",
                        description: Text(localizationManager.t("search_no_results_desc"))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, DS.Spacing.contentInset)
                } else {
                    List(viewModel.filteredArticles) { article in
                        NavigationLink {
                            ArticleDetailView(
                                viewModel: makeDetailViewModel(article, viewModel.articles),
                                localizationManager: localizationManager,
                                articleRowFactory: makeRowViewModel
                            )
                        } label: {
                            ArticleRow(viewModel: makeRowViewModel(article))
                                .frame(minHeight: DS.Size.hitTarget)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(DS.Color.background)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(DS.Color.background)
                }
            }
            .navigationTitle(localizationManager.t("tab_search"))
            .searchable(
                text: $viewModel.searchText,
                prompt: localizationManager.t("search_prompt")
            )
            .background(DS.Color.background)
            .task {
                guard !didInitialLoad else { return }
                didInitialLoad = true
                await viewModel.loadArticles()
            }
        }
    }

    /// Shortcut method to fetch localized translations using LocalizationManager.
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    SearchView(
        viewModel: container.makeSearchViewModel(),
        makeRowViewModel: container.makeArticleRowViewModel,
        makeDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        }
    )
    .environmentObject(container.localizationManager)
}
