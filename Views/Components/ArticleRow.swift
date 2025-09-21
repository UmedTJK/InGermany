//
//  ArticleRow.swift
//  InGermany
//

import SwiftUI

struct ArticleRow: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let article: Article                  // ВТОРОЙ параметр
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

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
                // 🔹 Мини-иконка категории
                if let category = CategoriesStore.shared.category(for: article.categoryId) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .blue)
                            .frame(width: 42, height: 42)
                        Image(systemName: category.icon)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    // 🔹 Метаданные (категория + дата + бейджи)
                    ArticleMetaView(article: article)

                    // 🔹 Анонс
                    Text(article.localizedContent(for: selectedLanguage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
