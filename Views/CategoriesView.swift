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
                    HStack(spacing: 12) {
                        // 🔹 Цветная иконка категории
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
            .navigationTitle(getTranslation(key: "Категории", language: selectedLanguage))
            .listStyle(PlainListStyle())
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
