//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

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
    
    private var readingTime: String {
        viewModel.article.formattedReadingTime(for: selectedLanguage)
    }

    private var relatedArticles: [Article] {
        let sameCategoryArticles = viewModel.allArticles.filter {
            $0.categoryId == viewModel.article.categoryId
        }
        let filteredArticles = sameCategoryArticles.filter {
            $0.id != viewModel.article.id
        }
        return Array(filteredArticles.prefix(3))
    }

    private var ratingBinding: Binding<Int> {
        Binding(
            get: { ratingManager.getRating(for: viewModel.article.id) },
            set: { ratingManager.setRating($0, for: viewModel.article.id) }
        )
    }

    private var currentFont: Font {
        let baseSize: CGFloat = 17
        let scaledSize = baseSize * textSizeManager.customScale
        return .system(size: scaledSize)
    }

    private var articleContent: String {
        viewModel.article.localizedContent(for: selectedLanguage)
    }

    private var articleImage: Image? {
        guard let imageName = viewModel.article.image,
              let uiImage = UIImage(named: imageName) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    private var progress: Double {
        tracker.progressForArticle(viewModel.article.id)
    }

    private var hasRelatedArticles: Bool {
        !relatedArticles.isEmpty
    }

    // MARK: - Инициализатор
    
    init(article: Article, allArticles: [Article]) {
        _viewModel = StateObject(wrappedValue: AppContainer.shared.makeArticleDetailViewModel(article: article, allArticles: allArticles))
    }

    // MARK: - Основное тело View
    
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

    private var articleContentSection: some View {
        Text(articleContent)
            .font(currentFont)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
            .background(contentHeightReader)
    }

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("Оцените статью"))
                .font(.headline)

            StarRatingView(rating: ratingBinding)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    private var relatedArticlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            relatedArticlesHeader
            relatedArticlesContent
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

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
    
    private func handleScrollOffset(_ value: CGFloat) {
        scrollOffset = -value
        let progressValue = max(0, min(scrollOffset / max(contentHeight - viewHeight, 1), 1))
        Task { @MainActor in
            tracker.updateProgress(for: viewModel.article.id, value: progressValue)
        }
    }

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
