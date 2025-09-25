//
//  ArticleView.swift
//  InGermany
//

import SwiftUI

struct ArticleView: View {
    let article: Article
    let allArticles: [Article]
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var ratingManager = RatingManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @StateObject private var readingTracker = ReadingTracker()
    @StateObject private var progressTracker = ReadingProgressTracker()
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
                    if let imageName = article.image,
                       let uiImage = UIImage(named: imageName, in: Bundle.main, with: nil) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image("Logo")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .clipped()
                            .cornerRadius(12)
                    }

                    ReadingProgressBar(
                        progress: progressTracker.scrollProgress,
                        height: 6,
                        foregroundColor: progressTracker.isReading ? .green : .blue
                    )
                    .padding(.bottom, 8)
                    
                    Text(article.localizedTitle(for: selectedLanguage))
                        .font(.title)
                        .bold()
                        .id("articleTop")

                    ArticleMetaView(article: article)

                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(article.formattedReadingTime(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if ReadingHistoryManager.shared.isRead(article.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                        
                        if progressTracker.isReading {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                    }

                    Text(article.localizedContent(for: selectedLanguage))
                        .font(textSizeManager.isCustomTextSizeEnabled ?
                              textSizeManager.currentFont : .body)
                        .foregroundColor(.primary)
                        .trackReadingProgress(progressTracker)
                        .lineSpacing(4)

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
                readingTracker.startReading(articleId: article.id)
                progressTracker.reset()
            }
            .onDisappear {
                readingTracker.finishReading()
                progressTracker.reset()
            }
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Оцените статью": [
                "ru": "Оцените статью", "en": "Rate this article", "de": "Artikel bewerten", "tj": "Мақоларо баҳогузорӣ кунед",
                "fa": "به این مقاله امتیاز دهید", "ar": "قيّم هذه المقالة", "uk": "Оцініть статтю"
            ],
            "Поделитесь этой статьёй": [
                "ru": "Поделитесь этой статьёй", "en": "Share this article", "de": "Artikel teilen", "tj": "Ин мақоларо мубодила кунед",
                "fa": "این مقاله را به اشتراک بگذارید", "ar": "شارك هذه المقالة", "uk": "Поділіться цією статтею"
            ],
            "Поделиться статьёй": [
                "ru": "Поделиться статьёй", "en": "Share article", "de": "Artikel teilen", "tj": "Мақоларо мубодила кунед",
                "fa": "اشتراک‌گذاری مقاله", "ar": "مشاركة المقالة", "uk": "Поділитися статтею"
            ],
            "Похожие статьи": [
                "ru": "Похожие статьи", "en": "Related articles", "de": "Ähnliche Artikel", "tj": "Мақолаҳои монанд",
                "fa": "مقالات مشابه", "ar": "مقالات مشابهة", "uk": "Схожі статті"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
