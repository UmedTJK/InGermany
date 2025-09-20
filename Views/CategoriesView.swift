import SwiftUI

struct CategoriesView: View {
    let categories: [Category]
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            List(categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: articles,
                        favoritesManager: favoritesManager
                    )
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(Color(hex: category.colorHex) ?? .blue)
                        Text(category.localizedName(for: selectedLanguage))
                    }
                }
            }
            .navigationTitle(getTranslation(key: "Категории", language: selectedLanguage))
            .listStyle(PlainListStyle()) // чтобы было без лишнего оформления
        }
    }

    // Локализация заголовка
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Категории": [
                "ru": "Категории",
                "en": "Categories",
                "de": "Kategorien",
                "tj": "Категорияҳо"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

#Preview {
    CategoriesView(
        categories: Category.sampleCategories,
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager()
    )
}
