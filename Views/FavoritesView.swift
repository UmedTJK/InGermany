//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
//
//
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var allArticles: [Article] = []

    // вычисляемые избранные статьи
    private var favorites: [Article] {
        favoritesManager.favoriteArticles(from: allArticles)
    }

    var body: some View {
        ScrollView {
            if favorites.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Нет избранных статей")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(favorites.enumerated()), id: \.offset) { index, tuple in
                        let article = tuple.element
                        NavigationLink(destination: ArticleView(article: article)) {
                            ArticleRow(article: article, favoritesManager: favoritesManager)
                                .scaleEffect(1.0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.05),
                                    value: favorites.count
                                )
                        }
                        .buttonStyle(.plain)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Избранное")
        .onAppear {
            allArticles = DataService.shared.loadArticles()
        }
        .animation(.easeInOut, value: favorites.count)
    }
}

#Preview {
    FavoritesView(favoritesManager: FavoritesManager())
}
