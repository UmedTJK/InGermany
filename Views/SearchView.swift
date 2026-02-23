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
                    searchEmptyState
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

    private var searchEmptyState: some View {
        VStack(spacing: DS.Spacing.section) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack(alignment: .center, spacing: DS.Spacing.m) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.t("search_no_results_title"))
                            .font(.headline)

                        Text(localizationManager.t("search_no_results_desc"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if !viewModel.searchText.isEmpty || viewModel.selectedTag != nil {
                    Button {
                        viewModel.searchText = ""
                        viewModel.selectedTag = nil
                    } label: {
                        Text(t("Сбросить"))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.s)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint(t("Очищает поиск и фильтры"))
                } else {
                    Text(t("Подсказка: попробуйте другой запрос или выберите тег"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(DS.Spacing.section)
            .cardContainer(.standard(useMaterial: true))

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .contain)
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
