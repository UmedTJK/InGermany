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
                    emptyState
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, DS.Spacing.section)
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

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.section) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack(alignment: .center, spacing: DS.Spacing.m) {
                    Image(systemName: emptyStateIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(emptyStateTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(emptyStateMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Text(t("Сбросить поиск"))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.s)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint(t("Очищает строку поиска и показывает все избранные статьи."))
                } else {
                    Text(t("Подсказка: откройте статью и нажмите ❤, чтобы добавить в избранное."))
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

    private var emptyStateIcon: String {
        searchText.isEmpty ? "heart" : "magnifyingglass"
    }

    private var emptyStateTitle: String {
        searchText.isEmpty
            ? t("Нет избранных статей")
            : t("Ничего не найдено")
    }

    private var emptyStateMessage: String {
        searchText.isEmpty
            ? t("Добавьте статьи в избранное, чтобы они появились здесь.")
            : t("Попробуйте другой запрос или очистите поиск.")
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
