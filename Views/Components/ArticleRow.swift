//
//  ArticleRow.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

//
import SwiftUI

struct ArticleRow: View {
    let article: Article
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    @State private var isPressed = false

    var isFavorite: Bool {
        favoritesManager.isFavorite(id: article.id)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let category = CategoryManager.shared.category(for: article.categoryId) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Text(category.localizedName(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    favoritesManager.toggleFavorite(id: article.id)
                }
            }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .scaleEffect(isFavorite ? 1.3 : 1.0) // эффект увеличения при добавлении
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.96 : 1.0) // нажатие на карточку
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    isPressed = false
                }
            }
        }
        // свайп влево для добавления/удаления из избранного
        .swipeActions {
            Button {
                favoritesManager.toggleFavorite(id: article.id)
            } label: {
                Label(isFavorite ? "Удалить" : "В избранное",
                      systemImage: isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)
        }
    }
}

#Preview {
    ArticleRow(
        article: Article(
            id: "1",
            title: ["ru": "Заголовок", "en": "Title", "de": "Titel"],
            content: ["ru": "Содержимое", "en": "Content", "de": "Inhalt"],
            categoryId: "1",
            tags: ["финансы", "налоги"]
        ),
        favoritesManager: FavoritesManager()
    )
}
