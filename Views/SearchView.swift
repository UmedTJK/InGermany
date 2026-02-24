//
//  SearchView.swift
//  InGermany
//

import SwiftUI

/// Provides a search interface for articles and categories with tag filtering and navigation.
struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
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
                                .padding(.vertical, DS.Spacing.s)
                                .padding(.horizontal, DS.Spacing.m)
                                .cardContainer(.standard())
                        }
                        .buttonStyle(.plain)
                        .cardPressFeedback()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            EdgeInsets(
                                top: DS.Spacing.s,
                                leading: DS.Spacing.contentInset,
                                bottom: DS.Spacing.s,
                                trailing: DS.Spacing.contentInset
                            )
                        )
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                    .background(DS.Color.background)
                }
            }
            .navigationTitle("tab.search")
            .searchable(
                text: $viewModel.searchText,
                prompt: Text("search.prompt")
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
                        Text("search.empty.title")
                            .font(.headline)

                        Text("search.empty.description")
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
                        Text("common.reset_filters")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.s)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint(Text("search.reset_filters.hint"))
                } else {
                    Text("search.empty.hint")
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
}
