import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
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
                        hasFilters: selectedCategory != nil || !searchText.isEmpty,
                        selectedLanguage: selectedLanguage,
                        getTranslation: getTranslation
                    )
                } else {
                    favoritesList
                }
            }
            .navigationTitle(navigationTitle)
        }
        .searchable(text: $searchText, prompt: getTranslation(key: "Поиск в избранном", language: selectedLanguage))
    }
    
    private var navigationTitle: String {
        let baseTitle = getTranslation(key: "Избранное", language: selectedLanguage)
        return "\(baseTitle) (\(filteredFavoriteArticles.count))"
    }
    
    private var categoryFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: getTranslation(key: "Все", language: selectedLanguage),
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
                    article: article,
                    favoritesManager: favoritesManager
                )
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Все": ["ru": "Все", "en": "All", "de": "Alle", "tj": "Ҳама"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Нет избранного": ["ru": "Нет избранного", "en": "No favorites", "de": "Keine Favoriten", "tj": "Интихобшуда нест"],
            "Попробуйте другую категорию": ["ru": "Попробуйте выбрать другую категорию", "en": "Try selecting another category", "de": "Versuchen Sie eine andere Kategorie", "tj": "Категорияи дигарро интихоб кунед"],
            "Поиск в избранном": ["ru": "Поиск в избранном", "en": "Search favorites", "de": "Favoriten durchsuchen", "tj": "Дар интихобшуда ҷустуҷӯ"],
            "Ничего не найдено": ["ru": "Ничего не найдено", "en": "Nothing found", "de": "Nichts gefunden", "tj": "Ҳеҷ чиз ёфт нашуд"],
            "Попробуйте другой запрос или категорию": ["ru": "Попробуйте другой запрос или категорию", "en": "Try another search or category", "de": "Versuchen Sie eine andere Suche oder Kategorie", "tj": "Ҳарфи дигар ё категорияи дигарро кӯшиш кунед"]
        ]
        return translations[key]?[language] ?? key
    }
}
