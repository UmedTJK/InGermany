//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var tracker = ReadingProgressTracker.shared
    @StateObject private var textSizeManager = TextSizeManager.shared
    @ObservedObject private var ratingManager = RatingManager.shared
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var viewHeight: CGFloat = 1
    
    private var readingTime: String {
        let minutes = ReadingTimeCalculator.estimateReadingTime(
            for: article.localizedContent(for: selectedLanguage),
            language: selectedLanguage
        )
        return ReadingTimeCalculator.formatReadingTime(minutes, language: selectedLanguage)
    }
    
    private var relatedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.prefix(3))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self,
                                    value: geo.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Заголовок
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.title)
                        .bold()
                    
                    // Время чтения
                    Text(readingTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Контент статьи
                    Text(article.localizedContent(for: selectedLanguage))
                        .font(textSizeManager.currentFont)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .background(GeometryReader { proxy in
                            Color.clear.onAppear {
                                contentHeight = proxy.size.height
                            }
                        })
                    
                    // Рейтинг
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("Оцените статью"))
                            .font(.subheadline)
                            .bold()
                        StarRatingView(
                            rating: Binding(
                                get: { ratingManager.rating(for: article.id) },
                                set: { ratingManager.setRating($0, for: article.id) }
                            )
                        )
                    }
                    .padding(.top)
                    
                    // Рекомендации
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("Вам может понравиться"))
                            .font(.headline)
                        
                        ForEach(relatedArticles, id: \.id) { related in
                            NavigationLink(destination: ArticleDetailView(article: related,
                                                                         allArticles: allArticles,
                                                                         favoritesManager: favoritesManager)) {
                                Text(related.localizedTitle(for: selectedLanguage))
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
                let progress = scrollOffset / max(contentHeight - viewHeight, 1)
                Task { @MainActor in
                    tracker.updateProgress(for: article.id, value: progress)
                }
            }
            .background(GeometryReader { proxy in
                Color.clear.onAppear {
                    viewHeight = proxy.size.height
                }
            })
            
            // Прогресс-бар
            let progress = tracker.progressForArticle(article.id)
            ReadingProgressHelper.progressView(progress: progress, language: selectedLanguage)
        }
        .navigationTitle(t("Статья"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: TextSizeSettingsPanel()) {
                    Image(systemName: "textformat.size")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(
                    item: article.localizedTitle(for: selectedLanguage) + "\n\n" +
                          article.localizedContent(for: selectedLanguage),
                    preview: SharePreview(article.localizedTitle(for: selectedLanguage))
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

// 🔹 PreferenceKey для отслеживания скролла
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
