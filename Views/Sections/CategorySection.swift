//
//  CategorySection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// Отображает горизонтально прокручиваемый список статей, отфильтрованных по категории.
struct CategorySection: View {
    /// Категория, для которой отображаются статьи
    let category: Category
    /// Список всех статей, из которых фильтруются по категории
    let articles: [Article]
    /// Менеджер избранного для интеграции с карточками статей
    let favoritesManager: FavoritesManager
    /// Код языка для локализации названия категории
    let language: String

    /// Строит секцию с заголовком категории и горизонтальной лентой статей
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.localizedName(for: language))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles.prefix(10)) { article in
                        NavigationLink {
                            ArticleDetailView(
                                article: article,
                                allArticles: articles
                            )
                        } label: {
                            /// Карточка компактного вида статьи, ведущая на её детальный экран
                            ArticleCompactCard(article: article)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 24)
    }
}

