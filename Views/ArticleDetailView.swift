//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    
    // MARK: - Dependencies
    private let localizationManager: LocalizationManager
    private let articleRowFactory: (Article) -> ArticleRowViewModel
    


    // MARK: - Init with DI
    init(
        viewModel: ArticleDetailViewModel,
        localizationManager: LocalizationManager,
        articleRowFactory: @escaping (Article) -> ArticleRowViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.localizationManager = localizationManager
        self.articleRowFactory = articleRowFactory
    }
    
    private var relatedArticles: [Article] {
        viewModel.relatedArticles(limit: 3)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Прогресс бар чтения
            ReadingProgressBar(
                progress: viewModel.progress,
                height: 3,
                foregroundColor: .blue,
                isReading: viewModel.progress > 0 && viewModel.progress < 1
            )
            .environmentObject(localizationManager)
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        // Изображение статьи
                        if let imageName = viewModel.article.image,
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
                            Text(viewModel.article.localizedTitle(for: selectedLanguage))
                                .font(viewModel.textSizeManager.titleFont)
                                .bold()
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Категория с фолбэком
                            Text(viewModel.categoryName(for: selectedLanguage))
                                .font(viewModel.textSizeManager.captionFont)
                                .foregroundColor(.blue)
                            
                            // Мета-информация
                            HStack {
                                Text("\(t("reading_time")): \(viewModel.articleFormatter.readingTime(viewModel.article, for: selectedLanguage)) \(t("min"))")
                                    .font(viewModel.textSizeManager.captionFont)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if viewModel.article.createdAt != nil {
                                    Text("\(t("published")): \(viewModel.articleFormatter.formattedCreatedDate(viewModel.article, for: selectedLanguage))")
                                        .font(viewModel.textSizeManager.captionFont)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Контент статьи
                        Text(viewModel.article.localizedContent(for: selectedLanguage))
                            .font(viewModel.textSizeManager.bodyFont)
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .background(
                                GeometryReader { contentGeometry in
                                    Color.clear
                                        .onAppear {
                                            viewModel.contentHeight = contentGeometry.size.height
                                        }
                                        .onChange(of: contentGeometry.size.height) { oldHeight, newHeight in
                                            viewModel.contentHeight = newHeight
                                        }
                                }
                            )
                        
                        // Рейтинг
                        VStack(alignment: .leading, spacing: 12) {
                            Text(t("article_rate"))
                                .font(viewModel.textSizeManager.headlineFont)
                            
                            StarRatingView(
                                rating: Binding(
                                    get: { viewModel.rating },
                                    set: { viewModel.setRating($0) }
                                )
                            )
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        
                        // Рекомендуемые статьи
                        if !relatedArticles.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(t("you_may_like"))
                                    .font(viewModel.textSizeManager.headlineFont)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(relatedArticles) { relatedArticle in
                                        NavigationLink {
                                            ArticleDetailView(
                                                viewModel: viewModel.createChildViewModel(for: relatedArticle),
                                                localizationManager: localizationManager,
                                                articleRowFactory: articleRowFactory
                                            )

                                        } label: {
                                            ArticleRow(viewModel: articleRowFactory(relatedArticle))
                                                .cardContainer()
                                                .padding(.vertical, DS.Spacing.xs)
                                                .frame(minHeight: DS.Size.hitTarget)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.vertical, 8)
                    .background(
                        GeometryReader { scrollGeometry in
                            Color.clear
                                .onChange(of: scrollGeometry.frame(in: .global).minY) { oldOffset, newOffset in
                                    viewModel.handleScrollOffset(newOffset)
                                }
                        }
                    )
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Кнопка размера шрифта
                    Button(action: {
                        viewModel.showTextSizePanel = true
                    }) {
                        Image(systemName: "textformat.size")
                    }
                    
                    // Кнопка шаринга
                    Button(action: {
                        shareItems = viewModel.shareItems(selectedLanguage: selectedLanguage)
                        isSharePresented = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    // Кнопка избранного
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite ? .red : .primary)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showTextSizePanel) {
            TextSizeSettingsPanel()
                .environmentObject(viewModel.textSizeManager)
        }
        .sheet(isPresented: $isSharePresented) {
            ActivityView(activityItems: shareItems)
        }
        .task {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.endReadingSession()
        }
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

#Preview {
    let container = AppContainer.previewMock()
    let vm = container.makeArticleDetailViewModel(article: Article.sampleArticles[0], allArticles: Article.sampleArticles)
    ArticleDetailView(
        viewModel: vm,
        localizationManager: container.localizationManager,
        articleRowFactory: container.makeArticleRowViewModel
    )
    .environmentObject(container)
}
