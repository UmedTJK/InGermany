import SwiftUI

/// Displays the user's list of favorite articles with search and navigation.
struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    init(
        viewModel: FavoritesViewModel,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
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

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.m) {
#if DEBUG
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
#endif

                if viewModel.isLoading {
                    ProgressView(t("Загрузка избранного..."))
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredFavoriteArticles.isEmpty {
                    ContentUnavailableView(
                        t("Нет избранных статей"),
                        systemImage: "heart",
                        description: Text(t("Добавьте статьи в избранное, чтобы они появились здесь."))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    favoritesList
                }
            }
            .background(DS.Color.background)
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
                    viewModel: makeDetailViewModel(article, viewModel.allArticles),
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

    private func getDataSourceColor() -> Color {
        switch viewModel.dataSource {
        case "network": return .green
        case "memory_cache": return .blue
        case "local": return .orange
        default: return .gray
        }
    }

    /// Унифицированная функция перевода
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    FavoritesView(
        viewModel: container.makeFavoritesViewModel(),
        makeRowViewModel: container.makeArticleRowViewModel,
        makeDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        }
    )
    .environmentObject(container.localizationManager)
}
