//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    // Для отслеживания скролла
    @State private var scrollViewContentSize: CGFloat = 0
    @State private var scrollViewVisibleSize: CGFloat = 0
    @State private var currentScrollOffset: CGFloat = 0

    init(article: Article, allArticles: [Article], appContainer: AppContainer) {
        self.article = article
        _viewModel = StateObject(wrappedValue: appContainer.makeArticleDetailViewModel(
            article: article,
            allArticles: allArticles
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // ✅ ИСПРАВЛЕНО: Правильное отслеживание скролла с реальным offset
            ScrollViewReader { proxy in
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

                        // Рекомендации
                        recommendationsView
                        
                        // ✅ ДОБАВИМ: Невидимый маркер для отслеживания конца контента
                        Color.clear
                            .frame(height: 1)
                            .id("content_end")
                    }
                    .padding(.vertical)
                    .background(
                        GeometryReader { contentGeometry in
                            Color.clear
                                .onAppear {
                                    scrollViewContentSize = contentGeometry.size.height
                                }
                                .onChange(of: contentGeometry.size.height) { oldValue, newValue in
                                    scrollViewContentSize = newValue
                                }
                        }
                    )
                }
                .background(
                    GeometryReader { scrollViewGeometry in
                        Color.clear
                            .onAppear {
                                scrollViewVisibleSize = scrollViewGeometry.size.height
                            }
                            .onChange(of: scrollViewGeometry.size.height) { oldValue, newValue in
                                scrollViewVisibleSize = newValue
                            }
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    currentScrollOffset = value
                    updateProgress()
                }
            }

            // ✅ ИСПРАВЛЕНО: Чистый прогресс-бар без тестовых кнопок
            progressBarView
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
    
    // ✅ Исправлено: используем readingStatsManager
    private func updateProgress() {
        guard scrollViewContentSize > 0, scrollViewVisibleSize > 0 else { return }
        
        let scrollProgress = max(0, min(-currentScrollOffset / (scrollViewContentSize - scrollViewVisibleSize), 1.0))
        
        viewModel.readingStatsManager.updateProgress(for: article.id, value: scrollProgress)
        
        print("📊 Real progress: \(Int(scrollProgress * 100))% (offset: \(currentScrollOffset))")
    }


    // MARK: - Subviews

    private var articleImageView: some View {
        Group {
            if let imageName = article.image,
               let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
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
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).minY
                        )
                }
            )
    }

    private var ratingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.t("Оцените статью", lang: selectedLanguage))
                .font(.headline)

            StarRatingView(rating: $viewModel.rating)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }

    private var recommendationsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.t("Рекомендуемые статьи", lang: selectedLanguage))
                .font(.title2)
                .bold()
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.recommendedArticles.prefix(5)) { recommendedArticle in
                        NavigationLink {
                            ArticleDetailView(
                                article: recommendedArticle,
                                allArticles: viewModel.allArticles,
                                appContainer: viewModel.appContainer
                            )
                        } label: {
                            ArticleCompactCard(
                                viewModel: viewModel.appContainer.makeArticleRowViewModel(
                                    article: recommendedArticle
                                )
                            )
                            .frame(width: 280)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    // ✅ ИСПРАВЛЕНО: Чистый прогресс-бар без лишних кнопок
    private var progressBarView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Прогресс чтения")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 6)
                    .foregroundColor(.gray.opacity(0.2))
                
                Capsule()
                    .frame(
                        width: max((UIScreen.main.bounds.width - 32) * CGFloat(viewModel.progress), 6),
                        height: 6
                    )
                    .foregroundColor(.blue)
                    .animation(.spring(response: 0.5), value: viewModel.progress)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                    .foregroundColor(viewModel.isFavorite ? .yellow : .primary)
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

// ✅ ДОБАВИМ: Key для отслеживания скролла
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
