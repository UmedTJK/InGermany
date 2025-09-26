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
    @StateObject private var readingTracker = ReadingTracker()
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var viewHeight: CGFloat = 1
    @State private var showRelatedArticles = false
    
    private var readingTime: String {
        article.formattedReadingTime(for: selectedLanguage)
    }
    
    private var relatedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.prefix(3))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // Изображение статьи
                    if let imageName = article.image,
                       let uiImage = UIImage(named: imageName, in: .main, with: nil) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    // Заголовок и мета-информация
                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.localizedTitle(for: selectedLanguage))
                            .font(.title)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // 🔹 ИСПРАВЛЕНО: убран лишний параметр language
                        ArticleMetaView(article: article)
                            .environmentObject(CategoriesStore.shared)
                    }
                    .padding(.horizontal)
                    
                    // Контент статьи
                    Text(article.localizedContent(for: selectedLanguage))
                        .font(textSizeManager.currentFont)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .background(GeometryReader { proxy in
                            Color.clear.onAppear {
                                contentHeight = proxy.size.height
                            }
                        })
                    
                    // Рейтинг
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t("Оцените статью"))
                            .font(.headline)
                        
                        StarRatingView(
                            rating: Binding(
                                get: { ratingManager.rating(for: article.id) },
                                set: { ratingManager.setRating($0, for: article.id) }
                            )
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    // Рекомендуемые статьи
                    if !relatedArticles.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(t("Вам может понравиться"))
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(showRelatedArticles ? t("Скрыть") : t("Показать")) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showRelatedArticles.toggle()
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            
                            if showRelatedArticles {
                                LazyVStack(spacing: 12) {
                                    ForEach(relatedArticles, id: \.id) { relatedArticle in
                                        NavigationLink {
                                            ArticleDetailView(
                                                article: relatedArticle,
                                                allArticles: allArticles,
                                                favoritesManager: favoritesManager
                                            )
                                        } label: {
                                            ArticleRow(article: relatedArticle)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                }
                .padding(.vertical)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
                let progress = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
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
            ReadingProgressBar(
                progress: progress,
                height: 4,
                foregroundColor: .blue,
                isReading: true
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Кнопка избранного
                // 🔹 ИСПРАВЛЕНО: добавлен параметр id:
                Button {
                    favoritesManager.toggleFavorite(id: article.id)
                } label: {
                    Image(systemName: favoritesManager.isFavorite(id: article.id) ? "star.fill" : "star")
                        .foregroundColor(favoritesManager.isFavorite(id: article.id) ? .yellow : .primary)
                }
                
                // Кнопка настроек текста
                NavigationLink(destination: TextSizeSettingsPanel()) {
                    Image(systemName: "textformat.size")
                }
                
                // Кнопка поделиться
                ShareLink(
                    item: shareContent(),
                    preview: SharePreview(
                        article.localizedTitle(for: selectedLanguage),
                        image: Image(systemName: "doc.text")
                    )
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            // Начинаем отслеживание времени чтения
            readingTracker.startReading(articleId: article.id)
        }
        .onDisappear {
            // Завершаем отслеживание времени чтения
            readingTracker.finishReading()
        }
    }
    
    private func shareContent() -> String {
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let readingTime = article.formattedReadingTime(for: selectedLanguage)
        
        return """
        \(title)
        
        \(content)
        
        \(t("Время чтения")): \(readingTime)
        \(t("Опубликовано")): \(article.formattedCreatedDate(for: selectedLanguage))
        """
    }
    
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

// Вспомогательная структура для отслеживания скролла
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
