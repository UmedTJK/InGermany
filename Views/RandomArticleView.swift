//
//  RandomArticleView.swift
//  InGermany
//

import SwiftUI

struct RandomArticleView: View {
    let articles: [Article]
    let favoritesManager: FavoritesManager

    @State private var randomArticle: Article?

    var body: some View {
        Group {
            if let article = randomArticle {
                ArticleView(
                    article: article,
                    allArticles: articles,
                    favoritesManager: favoritesManager
                )
            } else {
                VStack(spacing: 16) {
                    Text("Нет доступных статей")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Button("Выбрать снова") {
                        pickRandomArticle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .onAppear {
            pickRandomArticle()
        }
        .navigationTitle("Случайная статья")
    }

    private func pickRandomArticle() {
        randomArticle = articles.randomElement()
    }
}

#Preview {
    RandomArticleView(
        articles: [Article.sampleArticle],
        favoritesManager: FavoritesManager()
    )
}
