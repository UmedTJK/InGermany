//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let allArticles: [Article]
    
    @EnvironmentObject private var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var viewHeight: CGFloat = 1
    @State private var showRelatedArticles = false
    @State private var showTextSizePanel = false
    
    private var readingTime: String {
        article.formattedReadingTime(for: selectedLanguage)
    }
    
    private var relatedArticles: [Article] {
        Array(allArticles.filter { $0.categoryId == article.categoryId && $0.id != article.id }.prefix(3))
    }
    
    private var currentFont: Font {
        let scale = appContainer.textSizeManager.customScale
        return .system(size: 16 * scale)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // Изображение статьи
                    articleImageView
                    
                    // Заголовок и мета-информация
                    titleAndMetaView
                    
                    // Контент статьи
                    contentView
                    
                    // Рейтинг
                    ratingView
                    
                    // Рекомендуемые статьи
                   // recommendedArticlesView
                }
                .padding(.vertical)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffset(value)
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        viewHeight = proxy.size.height
                    }
                }
            )
            
            // Прогресс-бар
            progressBarView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItems
        }
        .sheet(isPresented: $showTextSizePanel) {
            TextSizeSettingsPanel()
                .environmentObject(appContainer)
        }
        .onAppear {
            startReadingSession()
        }
        .onDisappear {
            endReadingSession()
        }
    }
    
    // MARK: - Subviews
    
    private var articleImageView: some View {
        Group {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName, in: .main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }
    
    private var titleAndMetaView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
            
            ArticleMetaView(article: article)
                .environmentObject(appContainer)
        }
        .padding(.horizontal)
    }
    
    private var contentView: some View {
        Text(article.localizedContent(for: selectedLanguage))
            .font(currentFont)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        contentHeight = proxy.size.height
                    }
                }
            )
    }
    
    private var ratingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("Оцените статью"))
                .font(.headline)
            
            StarRatingView(
                rating: Binding(
                    get: { appContainer.ratingManager.getRating(for: article.id) },
                    set: { appContainer.ratingManager.setRating($0, for: article.id) }
                )
            )
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
   /*
    private var recommendedArticlesView: some View {
        Group {
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
                                        allArticles: allArticles
                                    )
                                    .environmentObject(appContainer)
                                } label: {
                                    ArticleRow(article: relatedArticle)
                                        .environmentObject(appContainer)
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
    }
    */
    
    private var progressBarView: some View {
        let progress = appContainer.readingProgressTracker.progressForArticle(article.id)
        return ReadingProgressBar(
            progress: progress,
            height: 4,
            foregroundColor: .blue,
            isReading: true
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            // Кнопка избранного
            Button {
                appContainer.favoritesManager.toggleFavorite(for: article.id)
            } label: {
                Image(systemName: appContainer.favoritesManager.isFavorite(article.id) ? "star.fill" : "star")
                    .foregroundColor(appContainer.favoritesManager.isFavorite(article.id) ? .yellow : .primary)
            }
            
            // Кнопка настроек текста
            Button {
                showTextSizePanel.toggle()
            } label: {
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
    
    // MARK: - Helper Methods
    
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
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
    
    private func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let progress = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
        
        Task { @MainActor in
            appContainer.readingProgressTracker.updateProgress(for: article.id, value: progress)
        }
    }
    
    private func startReadingSession() {
        appContainer.readingTimeTracker.startSession(articleId: article.id)
    }
    
    private func endReadingSession() {
        appContainer.readingTimeTracker.endSession(articleId: article.id)
        appContainer.historyManager.addReadingEntry(articleId: article.id, readingTime: 60)
    }
}

// MARK: - Supporting Types

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ArticleDetailView(
            article: Article.sampleArticles[0],
            allArticles: Article.sampleArticles
        )
        .environmentObject(appContainer)
    }
}
