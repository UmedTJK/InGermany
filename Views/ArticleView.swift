//
//  ArticleView.swift
//  InGermany
//

import SwiftUI
import UIKit

struct ArticleView: View {
    let article: Article
    let allArticles: [Article]             // 🔹 список всех статей
    let favoritesManager: FavoritesManager

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @EnvironmentObject private var readingHistoryManager: ReadingHistoryManager
    @EnvironmentObject private var ratingManager: RatingManager

    @State private var isFavorite: Bool = false
    @State private var tracker = ReadingTracker()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                // Даты
                if article.createdAt != nil {
                    Text(article.formattedCreatedDate(for: selectedLanguage))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if article.updatedAt != nil {
                    Text(article.formattedUpdatedDate(for: selectedLanguage))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Содержимое
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .padding(.top, 8)

                // Время чтения
                Text(article.formattedReadingTime(for: selectedLanguage))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                // Рейтинг
                HStack {
                    Text(LocalizationManager.shared.translate("RateArticle"))
                    Spacer()
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: (ratingManager.rating(for: article.id) ?? 0) >= star ? "star.fill" : "star")
                            .onTapGesture { ratingManager.setRating(for: article.id, rating: star) }
                    }
                }
                .padding(.vertical, 8)

                // Поделиться
                Button(action: shareArticle) {
                    Label(
                        LocalizationManager.shared.translate("ShareThisArticle"),
                        systemImage: "square.and.arrow.up"
                    )
                }
                .padding(.top, 8)

                // Похожие статьи
                RelatedArticlesView(
                    currentArticle: article,
                    favoritesManager: favoritesManager,
                    articles: allArticles              // 🔹 передаём все статьи
                )
            }
            .padding()
        }
        .onAppear {
            isFavorite = favoritesManager.isFavorite(article: article)
            tracker.startReading(articleId: article.id)
        }
        .onDisappear {
            tracker.finishReading()
        }
        .navigationTitle(article.localizedTitle(for: selectedLanguage))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .primary)
                }
            }
        }
    }

    private func toggleFavorite() {
        favoritesManager.toggleFavorite(article: article)
        isFavorite = favoritesManager.isFavorite(article: article)
    }

    private func shareArticle() {
        let text = "\(article.localizedTitle(for: selectedLanguage))\n\n\(article.localizedContent(for: selectedLanguage))"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

#Preview {
    ArticleView(
        article: Article.sampleArticle,
        allArticles: Article.sampleArticles,   // 🔹 проброс для превью
        favoritesManager: FavoritesManager()
    )
    .environmentObject(CategoriesStore())
    .environmentObject(ReadingHistoryManager.example)
    .environmentObject(RatingManager.example)
}
