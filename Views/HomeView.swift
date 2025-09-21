//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    let favoritesManager: FavoritesManager
    let articles: [Article]
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 1. Полезные инструменты
                UsefulToolsSection()

                // 2. Недавно прочитанные
                RecentlyReadSection(
                    favoritesManager: favoritesManager,
                    articles: articles
                )
                .environmentObject(categoriesStore)

                // 3. Работа
                if let work = categoriesStore.categories.first(where: { $0.name["ru"] == "Работа" }) {
                    CategorySection(
                        category: work,
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .environmentObject(categoriesStore)
                }

                // 4. Учёба
                if let study = categoriesStore.categories.first(where: { $0.name["ru"] == "Учёба" }) {
                    CategorySection(
                        category: study,
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .environmentObject(categoriesStore)
                }

                // 5. Бюрократия
                if let buro = categoriesStore.categories.first(where: { $0.name["ru"] == "Бюрократия" }) {
                    CategorySection(
                        category: buro,
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .environmentObject(categoriesStore)
                }

                // 6. Финансы
                if let finance = categoriesStore.categories.first(where: { $0.name["ru"] == "Финансы" }) {
                    CategorySection(
                        category: finance,
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .environmentObject(categoriesStore)
                }

                // 7. Жизнь
                if let life = categoriesStore.categories.first(where: { $0.name["ru"] == "Жизнь" }) {
                    CategorySection(
                        category: life,
                        favoritesManager: favoritesManager,
                        articles: articles
                    )
                    .environmentObject(categoriesStore)
                }

                // 8. Все статьи
                AllArticlesSection(
                    favoritesManager: favoritesManager,
                    articles: articles
                )
                .environmentObject(categoriesStore)
            }
            .padding(.vertical)
        }
        .navigationTitle(
            LocalizationManager.shared.translate("HomeTab")
        )
    }
}

#Preview {
    HomeView(
        favoritesManager: FavoritesManager(),
        articles: Article.sampleArticles
    )
    .environmentObject(CategoriesStore())
}
