import SwiftUI

struct CategoriesView: View {
    let categories: [Category]
    let articles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    let selectedLanguage: String   // 👈 принимаем язык как параметр

    var body: some View {
        NavigationView {
            List(categories) { category in
                NavigationLink {
                    ArticlesByCategoryView(
                        category: category,
                        articles: articles,
                        favoritesManager: favoritesManager,
                        selectedLanguage: selectedLanguage // 👈 пробрасываем дальше
                    )
                } label: {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(.blue)
                        Text(category.localizedName(for: selectedLanguage))
                    }
                }
            }
            .navigationTitle("Категории")
        }
    }
}

#Preview {
    CategoriesView(
        categories: Category.sampleCategories,
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager(),
        selectedLanguage: "ru"
    )
}
