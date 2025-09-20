//
//  ArticleView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var ratingManager = RatingManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    // Трекер чтения
    @StateObject private var readingTracker = ReadingTracker()
    @StateObject private var progressTracker = ReadingProgressTracker()
    
    // Менеджер размера текста
    @StateObject private var textSizeManager = TextSizeManager.shared
    @State private var showTextSizePanel = false
    
    private var relatedArticles: [Article] {
        allArticles
            .filter { $0.categoryId == article.categoryId && $0.id != article.id }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 🔹 Прогресс-бар чтения
                    ReadingProgressBar(
                        progress: progressTracker.scrollProgress,
                        height: 6,
                        foregroundColor: progressTracker.isReading ? .green : .blue
                    )
                    .padding(.bottom, 8)
                    
                    // 🔹 Время чтения и индикаторы
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(article.formattedReadingTime(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Индикатор прочитанности
                        if ReadingHistoryManager.shared.isRead(article.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                        
                        // Индикатор чтения в реальном времени
                        if progressTracker.isReading {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                    }
                    .padding(.bottom, 8)

                    // 🔹 Заголовок
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.title)
                        .bold()
                        .id("articleTop")

                    // 🔹 Категория
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)

                        Text(
                            CategoryManager.shared
                                .category(for: article.categoryId)?
                                .localizedName(for: selectedLanguage)
                            ?? "Без категории"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    // 🔹 Контент статьи с отслеживанием скролла и кастомным размером
                    Text(article.localizedContent(for: selectedLanguage))
                        .font(textSizeManager.isCustomTextSizeEnabled ?
                              textSizeManager.currentFont : .body)
                        .foregroundColor(.primary)
                        .trackReadingProgress(progressTracker)
                        .lineSpacing(4)

                    // 🔹 Рейтинг
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getTranslation(key: "Оцените статью", language: selectedLanguage))
                            .font(.subheadline)
                        HStack {
                            ForEach(1..<6) { star in
                                Image(systemName: star <= ratingManager.rating(for: article.id) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        ratingManager.setRating(star, for: article.id)
                                        HapticFeedback.medium()
                                    }
                            }
                        }
                    }
                    .padding(.top)

                    // 🔹 Кнопка "Поделиться"
                    ShareLink(
                        item: "\(article.localizedTitle(for: selectedLanguage))\n\n\(article.localizedContent(for: selectedLanguage))",
                        subject: Text(article.localizedTitle(for: selectedLanguage)),
                        message: Text(getTranslation(key: "Поделитесь этой статьёй", language: selectedLanguage))
                    ) {
                        Label(
                            getTranslation(key: "Поделиться статьёй", language: selectedLanguage),
                            systemImage: "square.and.arrow.up"
                        )
                        .padding(.top)
                    }

                    // 🔹 Похожие статьи
                    if !relatedArticles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(getTranslation(key: "Похожие статьи", language: selectedLanguage))
                                .font(.headline)
                                .padding(.top)

                            ForEach(relatedArticles) { related in
                                NavigationLink(destination: ArticleView(
                                    article: related,
                                    allArticles: allArticles,
                                    favoritesManager: favoritesManager
                                )) {
                                    VStack(alignment: .leading) {
                                        Text(related.localizedTitle(for: selectedLanguage))
                                            .font(.subheadline)
                                            .bold()
                                        Text(related.localizedContent(for: selectedLanguage))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(article.localizedTitle(for: selectedLanguage))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Кнопка настроек текста
                    Button {
                        showTextSizePanel.toggle()
                        HapticFeedback.medium()
                    } label: {
                        Image(systemName: "textformat.size")
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        favoritesManager.toggleFavorite(article: article)
                        HapticFeedback.medium()
                    } label: {
                        Image(
                            systemName: favoritesManager.isFavorite(article: article)
                            ? "star.fill"
                            : "star"
                        )
                        .foregroundColor(.yellow)
                    }
                    
                    // Кнопка для прокрутки к началу
                    Button {
                        withAnimation {
                            proxy.scrollTo("articleTop", anchor: .top)
                        }
                        HapticFeedback.light()
                    } label: {
                        Image(systemName: "arrow.up.to.line.compact")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showTextSizePanel) {
                TextSizeSettingsPanel()
            }
            .onAppear {
                // Начинаем отслеживание чтения
                readingTracker.startReading(articleId: article.id)
                progressTracker.reset()
                
                // Прокручиваем к началу при открытии
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo("articleTop", anchor: .top)
                    }
                }
            }
            .onDisappear {
                // Завершаем отслеживание чтения
                readingTracker.finishReading()
                progressTracker.reset()
            }
        }
    }
    
    // MARK: - Локализация
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Оцените статью": [
                "ru": "Оцените статью",
                "en": "Rate this article",
                "de": "Bewerten Sie diesen Artikel",
                "tj": "Мақоларо баҳо диҳед"
            ],
            "Поделитесь этой статьёй": [
                "ru": "Поделитесь этой статьёй",
                "en": "Share this article",
                "de": "Teilen Sie diesen Artikel",
                "tj": "Ин мақоларо мубодила кунед"
            ],
            "Поделиться статьёй": [
                "ru": "Поделиться статьёй",
                "en": "Share article",
                "de": "Artikel teilen",
                "tj": "Мақоларо мубодила кунед"
            ],
            "Похожие статьи": [
                "ru": "Похожие статьи",
                "en": "Related articles",
                "de": "Ähnliche Artikel",
                "tj": "Мақолаҳои монанд"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

#Preview {
    NavigationView {
        ArticleView(
            article: Article.sampleArticle,
            allArticles: DataService.shared.loadArticles(),
            favoritesManager: FavoritesManager()
        )
    }
}
