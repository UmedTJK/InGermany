import SwiftUI

/// Displays a list of article categories with navigation into category-specific articles.
struct CategoriesView: View {

    @StateObject private var viewModel: CategoriesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    init(
        viewModel: CategoriesViewModel,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.categories) { category in
                NavigationLink(value: category) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: category.colorHex) ?? .blue)
                                .frame(width: 32, height: 32)
                            Image(systemName: category.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        Text(category.localizedName(for: selectedLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(t("tab_categories"))
            .listStyle(PlainListStyle())
            .task {
                await viewModel.load()
            }
            .navigationDestination(for: Category.self) { category in
                ArticlesByCategoryView(
                    category: category,
                    articles: viewModel.articles(for: category.id),
                    localizationManager: localizationManager,
                    articleRowFactory: makeRowViewModel,
                    articleDetailFactory: { article, allArticles in
                        makeDetailViewModel(article, allArticles)
                    }
                )
            }
        }
    }

    /// Provides localized strings for UI elements.
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    CategoriesView(
        viewModel: container.makeCategoriesViewModel(),
        makeRowViewModel: container.makeArticleRowViewModel,
        makeDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        }
    )
    .environmentObject(container.localizationManager)
}
