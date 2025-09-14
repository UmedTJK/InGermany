//
//  ArticlesByCategoryView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

///
import SwiftUI

struct ArticlesByCategoryView: View {
    let category: Category
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var articles: [Article] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, tuple in
                    let article = tuple.element
                    NavigationLink(destination: ArticleView(article: article)) {
                        ArticleRow(article: article, favoritesManager: favoritesManager)
                            .scaleEffect(1.0)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.05),
                                value: articles.count
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding()
        }
        .navigationTitle(category.localizedName(for: selectedLanguage))
        .onAppear {
            articles = DataService.shared.loadArticles().filter { $0.categoryId == category.id }
        }
    }
}

#Preview {
    NavigationView {
        ArticlesByCategoryView(
            category: Category(id: "1", name: ["ru": "Финансы", "en": "Finance", "de": "Finanzen"], icon: "dollarsign.circle"),
            favoritesManager: FavoritesManager()
        )
    }
}
