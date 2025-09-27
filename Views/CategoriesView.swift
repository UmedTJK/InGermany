//
//  CategoriesView.swift
//  InGermany
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var repo = CategoriesRepository.shared
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            List(repo.categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: articles,                  // ⬅️ передаём как есть
                        favoritesManager: favoritesManager
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
            .task {                                  // ⬅️ загрузка категорий
                await repo.bootstrap()
            }
        }
    }

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
