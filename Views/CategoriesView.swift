//
//  CategoriesView.swift
//  InGermany
//

import SwiftUI

struct CategoriesView: View {
    let favoritesManager: FavoritesManager
    let articles: [Article]
    let categories: [Category]

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    NavigationLink(
                        destination: ArticlesByCategoryView(
                            category: category,
                            favoritesManager: favoritesManager,   // порядок исправлен
                            articles: articles
                        )
                    ) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Color(hex: category.colorHex))
                                .frame(width: 28, height: 28)

                            Text(category.localizedName(for: selectedLanguage))
                                .font(.body)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(
                LocalizationManager.shared.translate("CategoriesTab")
            )
        }
    }
}

#Preview {
    CategoriesView(
        favoritesManager: FavoritesManager(),
        articles: Article.sampleArticles,
        categories: Category.sampleCategories
    )
}
