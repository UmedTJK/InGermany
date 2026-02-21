import SwiftUI

/// Displays a list of article categories with navigation into category-specific articles.
struct CategoriesView: View {

    @StateObject private var viewModel: CategoriesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject var appContainer: AppContainer

    /// Основной init через DI
    init(appContainer: AppContainer) {
        _viewModel = StateObject(wrappedValue: appContainer.makeCategoriesViewModel())
    }

    /// Для превью и тестов
    init(viewModel: CategoriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    localizationManager: appContainer.localizationManager,
                    articleRowFactory: appContainer.makeArticleRowViewModel,
                    articleDetailFactory: { article, allArticles in
                        appContainer.makeArticleDetailViewModel(
                            article: article,
                            allArticles: allArticles
                        )
                    }
                )
                .environmentObject(appContainer)
            }
        }
    }

    /// Provides localized strings for UI elements.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    CategoriesView(appContainer: AppContainer.previewMock())
        .environmentObject(AppContainer.previewMock())
}
