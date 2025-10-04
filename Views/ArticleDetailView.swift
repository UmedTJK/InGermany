//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

/// A view that displays the full details of an article, including image, content, rating, reading progress, and related articles.
struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject private var tracker = ReadingProgressTracker.shared
    @StateObject private var textSizeManager = TextSizeManager.shared
    @ObservedObject private var ratingManager = RatingManager.shared
    @StateObject private var readingTimeTracker = ReadingTimeTracker.shared

    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var viewHeight: CGFloat = 1
    @State private var showRelatedArticles = false

    // MARK: - Вычисляемые свойства
    
    /// The formatted reading time string for the current article in the selected language.
    private var readingTime: String {
        viewModel.article.formattedReadingTime(for: selectedLanguage)
    }

    /// An array of related articles from the same category, excluding the current article, limited to three.
    private var relatedArticles: [Article] {
        let sameCategoryArticles = viewModel.allArticles.filter {
            $0.categoryId == viewModel.article.categoryId
        }
        let filteredArticles = sameCategoryArticles.filter {
            $0.id != viewModel.article.id
        }
        return Array(filteredArticles.prefix(3))
    }

    /// A binding to the current rating for the article, allowing read and write operations.
    private var ratingBinding: Binding<Int> {
        Binding(
            get: { ratingManager.getRating(for: viewModel.article.id) },
            set: { ratingManager.setRating($0, for: viewModel.article.id) }
        )
    }

    /// The font used for the article content, scaled according to user preferences.
    private var currentFont: Font {
        let baseSize: CGFloat = 17
        let scaledSize = baseSize * textSizeManager.customScale
        return .system(size: scaledSize)
    }

    /// The localized content text of the article for the selected language.
    private var articleContent: String {
        viewModel.article.localizedContent(for: selectedLanguage)
    }

    /// The image associated with the article, if available.
    private var articleImage: Image? {
        guard let imageName = viewModel.article.image,
              let uiImage = UIImage(named: imageName) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    /// The current reading progress for the article, as a value between 0 and 1.
    private var progress: Double {
        tracker.progressForArticle(viewModel.article.id)
    }

    /// A Boolean indicating whether there are related articles to display.
    private var hasRelatedArticles: Bool {
        !relatedArticles.isEmpty
    }

    // MARK: - Инициализатор
    
    /// Initializes the view with the given article and a list of all articles for related content context.
    /// - Parameters:
    ///   - article: The article to display.
    ///   - allArticles: The complete list of articles for determining related articles.
    init(article: Article, allArticles: [Article]) {
        _viewModel = StateObject(wrappedValue: AppContainer.shared.makeArticleDetailViewModel(article: article, allArticles: allArticles))
    }

    // MARK: - Основное тело View
    
    /// The main view layout combining the scrollable content and the reading progress bar.
    var body: some View {
        VStack(spacing: 0) {
            scrollContent
            progressBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onAppear {
            viewModel.markAsRead()
            readingTimeTracker.startSession(articleId: viewModel.article.id)
        }
        .onDisappear {
            readingTimeTracker.endSession(articleId: viewModel.article.id)
        }
    }

    // MARK: - Основные компоненты
    
    /// The scrollable content area containing the article image, header, content, rating, and related articles.
    private var scrollContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                articleImageSection
                articleHeaderSection
                articleContentSection
                ratingSection
                
                if hasRelatedArticles {
                    relatedArticlesSection
                }
            }
            .padding(.vertical)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            handleScrollOffset(value)
        }
        .background(viewHeightReader)
    }

    /// The section displaying the article's main image, if available.
    private var articleImageSection: some View {
        Group {
            if let articleImage = articleImage {
                articleImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }

    /// The section showing the article's title and meta information.
    private var articleHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.article.localizedTitle(for: selectedLanguage))
                .font(.title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)

            ArticleMetaView(article: viewModel.article)
        }
        .padding(.horizontal)
    }

    /// The section containing the main text content of the article.
    private var articleContentSection: some View {
        Text(articleContent)
            .font(currentFont)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
            .background(contentHeightReader)
    }

    /// The section allowing the user to rate the article.
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("Оцените статью"))
                .font(.headline)

            StarRatingView(rating: ratingBinding)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    /// The section displaying related articles with a header and expandable list.
    private var relatedArticlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            relatedArticlesHeader
            relatedArticlesContent
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    /// The header for the related articles section, including a toggle button to show or hide related articles.
    private var relatedArticlesHeader: some View {
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
    }

    /// The content area listing related articles when expanded.
    @ViewBuilder
    private var relatedArticlesContent: some View {
        if showRelatedArticles {
            LazyVStack(spacing: 12) {
                ForEach(relatedArticles, id: \.id) { relatedArticle in
                    NavigationLink {
                        ArticleDetailView(
                            article: relatedArticle,
                            allArticles: viewModel.allArticles
                        )
                    } label: {
                        ArticleRow(viewModel: ArticleRowViewModel(article: relatedArticle))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    /// The progress bar showing the user's reading progress through the article.
    private var progressBar: some View {
        ReadingProgressBar(
            progress: progress,
            height: 4,
            foregroundColor: .blue,
            isReading: true
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var viewHeightReader: some View {
        GeometryReader { proxy in
            Color.clear.onAppear {
                viewHeight = proxy.size.height
            }
        }
    }

    private var contentHeightReader: some View {
        GeometryReader { proxy in
            Color.clear.onAppear {
                contentHeight = proxy.size.height
            }
        }
    }

    // MARK: - Toolbar
    
    /// The navigation bar toolbar content including favorite, text size, and share buttons.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            favoriteButton
            textSizeButton
            shareButton
        }
    }

    private var favoriteButton: some View {
        Button {
            viewModel.toggleFavorite()
        } label: {
            Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                .foregroundColor(viewModel.isFavorite ? .yellow : .primary)
        }
    }

    private var textSizeButton: some View {
        NavigationLink(destination: TextSizeSettingsPanel()) {
            Image(systemName: "textformat.size")
        }
    }

    private var shareButton: some View {
        ShareLink(
            item: shareContent(),
            preview: SharePreview(
                viewModel.article.localizedTitle(for: selectedLanguage),
                image: Image(systemName: "doc.text")
            )
        ) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    // MARK: - Методы
    
    /// Handles updates to the scroll offset, calculating and updating the reading progress for the article.
    /// - Parameter value: The current scroll offset value.
    private func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let progressValue = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
        Task { @MainActor in
            tracker.updateProgress(for: viewModel.article.id, value: progressValue)
        }
    }

    /// Prepares the content string used for sharing the article, including title, content, reading time, and publication date.
    /// - Returns: A formatted string representing the share content.
    private func shareContent() -> String {
        let title = viewModel.article.localizedTitle(for: selectedLanguage)
        let content = viewModel.article.localizedContent(for: selectedLanguage)
        let readingTimeText = viewModel.article.formattedReadingTime(for: selectedLanguage)
        let publishedDate = viewModel.article.formattedCreatedDate(for: selectedLanguage)

        return """
        \(title)

        \(content)

        \(t("Время чтения")): \(readingTimeText)
        \(t("Опубликовано")): \(publishedDate)
        """
    }

    /// Translates a given key into the selected language.
    /// - Parameter key: The localization key to translate.
    /// - Returns: The localized string.
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
