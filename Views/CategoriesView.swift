import SwiftUI

/// Displays a list of article categories with navigation into category-specific articles.
struct CategoriesView: View {

    @StateObject private var viewModel: CategoriesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject var appContainer: AppContainer


    /// Initializes the view with AppContainer for dependency injection
    init() {
        // ✅ ИСПРАВЛЕНО: используем AppContainer.shared вместо параметра
        _viewModel = StateObject(wrappedValue: AppContainer.shared.makeCategoriesViewModel())
    }
    
    /// For preview and testing
    init(viewModel: CategoriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Builds a navigation list of categories leading to `ArticlesByCategoryView`.
    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: viewModel.articles(for: category.id)
                    )
                } label: {
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
            .navigationTitle(t("Категории"))
            .listStyle(PlainListStyle())
            .task {
                await viewModel.load()
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
    CategoriesView()
        .environmentObject(AppContainer.previewMock())
}
