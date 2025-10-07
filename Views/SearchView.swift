//
//  SearchView.swift
//  InGermany
//

import SwiftUI

/// Provides a search interface for articles and categories with tag filtering and navigation.
struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var appContainer: AppContainer

    /// Initializes the view with AppContainer for dependency injection
    init(appContainer: AppContainer) {
        _viewModel = StateObject(wrappedValue: appContainer.makeSearchViewModel())
    }
    
    /// For preview and testing
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Builds the main search interface with tag filter, searchable list of articles, and navigation to detail view.
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.allTags.isEmpty {
                    TagFilterView(tags: viewModel.allTags) { tag in
                        viewModel.selectedTag = (viewModel.selectedTag == tag) ? nil : tag
                    }
                    .padding(.horizontal)
                }
                List(viewModel.filteredArticles) { article in
                    NavigationLink {
                        ArticleDetailView(
                            article: article,
                            allArticles: viewModel.articles
                        )
                    } label: {
                        ArticleRow(viewModel: ArticleRowViewModel(
                            article: article,
                            favoritesManager: viewModel.favoritesManager,
                            ratingManager: appContainer.ratingManager
                        ))
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(t("Поиск"))
            .searchable(
                text: $viewModel.searchText,
                prompt: t("Искать по статьям или категориям")
            )
            .task {
                await viewModel.loadArticles()
            }
        }
    }

    /// Shortcut method to fetch localized translations using AppContainer's LocalizationManager.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    SearchView(appContainer: AppContainer.shared)
        .environmentObject(appContainer)
}
