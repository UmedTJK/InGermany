//
//  CategoriesView.swift
//  InGermany
//

import SwiftUI

/// Displays a list of article categories with navigation into category-specific articles.
struct CategoriesView: View {
    /// ViewModel responsible for loading and managing categories, and providing articles for the selected category.
    @StateObject private var viewModel: CategoriesViewModel
    /// Stores the current UI language.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Initializes the view with a provided or default CategoriesViewModel.
    init(viewModel: CategoriesViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AppContainer.shared.makeCategoriesViewModel())
    }

    /// Builds a navigation list of categories leading to `ArticlesByCategoryView`.
    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: viewModel.articles(for: category.id),
                        favoritesManager: FavoritesManager.shared
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
        return LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
