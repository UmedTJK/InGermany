//
//  CategoriesView.swift
//  InGermany
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel: CategoriesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init(viewModel: CategoriesViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AppContainer.shared.makeCategoriesViewModel())
    }

    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: viewModel.articles,
                        favoritesManager: viewModel.favoritesManager
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
                await viewModel.loadData()
            }
        }
    }

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
