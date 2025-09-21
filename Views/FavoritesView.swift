import SwiftUI

struct FavoritesView: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let articles: [Article]               // ВТОРОЙ параметр
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var selectedCategory: String? = nil
    @State private var searchText: String = ""
    @EnvironmentObject private var categoriesStore: CategoriesStore
    
    private var filteredFavoriteArticles: [Article] {
        let favorites = favoritesManager.favoriteArticles(from: articles)
        var filtered = favorites
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.categoryId == selectedCategory }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { article in
                let title = article.title[selectedLanguage] ?? article.title["ru"] ?? ""
                return title.localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered
    }
    
    private var favoriteCategories: [Category] {
        let favoriteArticles = favoritesManager.favoriteArticles(from: articles)
        let categoryIDs = Set(favoriteArticles.map { $0.categoryId })
        return categoriesStore.categories.filter { categoryIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !favoriteCategories.isEmpty && !filteredFavoriteArticles.isEmpty {
                    categoryFilterScrollView
                }
                if filteredFavoriteArticles.isEmpty {
                    EmptyFavoritesView(
                        hasFilters: selectedCategory != nil || !searchText.isEmpty
                    )
                } else {
                    favoritesList
                }
            }
            .navigationTitle(navigationTitle)
        }
        .searchable(
            text: $searchText,
            prompt: LocalizationManager.shared.translate("SearchInFavorites") // УБРАЛИ language
        )
    }
    
    private var navigationTitle: String {
        let baseTitle = LocalizationManager.shared.translate("Favorites") // УБРАЛИ language
        return "\(baseTitle) (\(filteredFavoriteArticles.count))"
    }
    
    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: LocalizationManager.shared.translate("All"), // УБРАЛИ language
                    isSelected: selectedCategory == nil,
                    systemImage: "star.fill"
                ) {
                    selectedCategory = nil
                }
                ForEach(favoriteCategories) { category in
                    CategoryFilterButton(
                        title: category.localizedName(for: selectedLanguage),
                        isSelected: selectedCategory == category.id,
                        systemImage: category.icon
                    ) {
                        selectedCategory = category.id
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
    
    private var favoritesList: some View {
        List(filteredFavoriteArticles) { article in
            NavigationLink {
                ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            } label: {
                ArticleRow(
                    favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                    article: article
                )
            }
        }
        .listStyle(PlainListStyle())
    }
}
