// FavoritesView.swift
import SwiftUI

/// Displays the user's list of favorite articles with search and navigation.
struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var searchText = ""
    @EnvironmentObject private var appContainer: AppContainer

    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var filteredFavoriteArticles: [Article] {
        let favoriteArticles = viewModel.favoriteArticles
        if searchText.isEmpty {
            return favoriteArticles
        } else {
            return favoriteArticles.filter {
                $0.localizedTitle(for: selectedLanguage).localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)

                if viewModel.isLoading {
                    ProgressView(t("Загрузка избранного..."))
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if filteredFavoriteArticles.isEmpty {
                        Text(t("Нет избранных статей"))
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        favoritesList
                    }
                }
            }
            .navigationTitle(t("tab_favorites"))
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: t("Поиск в избранном")
            )
            .task {
                await viewModel.loadFavorites()
            }
        }
    }

    private var favoritesList: some View {
        List(filteredFavoriteArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    viewModel: appContainer.makeArticleDetailViewModel(
                        article: article,
                        allArticles: viewModel.allArticles
                    ),
                    localizationManager: appContainer.localizationManager,
                    articleRowFactory: appContainer.makeArticleRowViewModel
                )
            } label: {
                ArticleRow(viewModel: appContainer.makeArticleRowViewModel(article: article))
            }
        }
        .listStyle(PlainListStyle())
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
