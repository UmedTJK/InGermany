//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init(article: Article, allArticles: [Article], appContainer: AppContainer) {
        self.article = article
        _viewModel = StateObject(wrappedValue: appContainer.makeArticleDetailViewModel(
            article: article,
            allArticles: allArticles
        ))
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
                }
                .padding(.vertical)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // ✅ ИСПРАВЛЕНО: Call to main actor-isolated method
                Task { @MainActor in
                    viewModel.handleScrollOffset(value)
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        viewModel.viewHeight = proxy.size.height
                    }
                }
            )

            // Прогресс-бар
            ReadingProgressBar(
                progress: viewModel.progress,
                height: 4,
                foregroundColor: .blue,
                isReading: true
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarItems
        }
        .sheet(isPresented: $viewModel.showTextSizePanel) {
            TextSizeSettingsPanel()
        }
        .onAppear {
            viewModel.startReadingSession()
        }
        .onDisappear {
            viewModel.endReadingSession()
        }
    }

    // MARK: - Subviews
    private var articleImageView: some View {
        // Здесь вставь свой UI для изображения статьи
        EmptyView()
    }

    private var titleAndMetaView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)

            ArticleMetaView(article: article)
        }
        .padding(.horizontal)
    }

    private var contentView: some View {
        Text(article.localizedContent(for: selectedLanguage))
            .font(viewModel.currentFont)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear {
                        viewModel.contentHeight = proxy.size.height
                    }
                }
            )
    }

    private var ratingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.t("Оцените статью", lang: selectedLanguage))
                .font(.headline)

            StarRatingView(
                rating: Binding(
                    get: { viewModel.getRating() },
                    set: { viewModel.setRating($0) }
                )
            )
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite() ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite() ? .yellow : .primary)
            }

            Button {
                viewModel.showTextSizePanel.toggle()
            } label: {
                Image(systemName: "textformat.size")
            }

            ShareLink(
                item: viewModel.shareContent(selectedLanguage: selectedLanguage),
                preview: SharePreview(article.localizedTitle(for: selectedLanguage))
            ) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
