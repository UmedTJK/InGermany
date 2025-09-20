//
//  ArticleRow.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    let favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore
    
    private var isFavorite: Bool {
        favoritesManager.isFavorite(article: article)
    }

    var body: some View {
        NavigationLink {
            ArticleDetailView(
                article: article,
                favoritesManager: favoritesManager
            )
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Text(
                            categoriesStore.categoryName(for: article.categoryId,
                                                         language: selectedLanguage)
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.system(size: 16))
            }
            .padding(.vertical, 8)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                toggleFavorite()
            } label: {
                Label(
                    isFavorite ? "Удалить" : "В избранное",
                    systemImage: isFavorite ? "heart.slash" : "heart.fill"
                )
            }
            .tint(isFavorite ? .gray : .red)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            ShareLink(item: article.localizedTitle(for: selectedLanguage)) {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
    }
    
    private func toggleFavorite() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            favoritesManager.toggleFavorite(article: article)
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
}
