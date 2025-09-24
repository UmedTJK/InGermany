//
//  ArticleCardView.swift
//  InGermany
//
//  Created by SUM TJK on 18.09.25.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    let favoritesManager: FavoritesManager
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
            VStack(alignment: .leading, spacing: 8) {
                // 🔹 Фото статьи (если есть)
                if let imageName = article.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                }

                // 🔹 Индикатор избранного в правом верхнем углу
                HStack {
                    Spacer()
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.system(size: 14))
                        .padding(4)
                }

                // 🔹 Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // 🔹 Анонс
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                // 🔹 Теги + время чтения
                HStack {
                    ForEach(article.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .shadow(radius: 2)
        }
        .contextMenu {
            Button {
                toggleFavorite()
            } label: {
                Label(
                    isFavorite ? "Удалить из избранного" : "Добавить в избранное",
                    systemImage: isFavorite ? "heart.slash" : "heart.fill"
                )
            }
            
            ShareLink(item: article.localizedTitle(for: selectedLanguage)) {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            
            Button {
                // Дополнительное действие (опционально)
            } label: {
                Label("Информация о статье", systemImage: "info.circle")
            }
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
