//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @State private var showRelatedArticles = false
    
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
                        // Изображение статьи - ИСПРАВЛЕННАЯ ВЕРСИЯ
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
                        
                        // Рейтинг - ИСПРАВЛЕННЫЕ КЛЮЧИ ЛОКАЛИЗАЦИИ
                        VStack(alignment: .leading, spacing: 12) {
                            Text(t("Оцените статью"))
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
                        
                        // Рекомендуемые статьи - ИСПРАВЛЕННЫЕ КЛЮЧИ ЛОКАЛИЗАЦИИ
                        if !relatedArticles.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(t("Вам может понравиться"))
                                        .font(viewModel.textSizeManager.headlineFont)
                                    
                                    Spacer()
                                    
                                    Button(showRelatedArticles ? t("Скрыть") : t("Показать")) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showRelatedArticles.toggle()
                                        }
                                    }
                                    .font(viewModel.textSizeManager.captionFont)
                                }
                                
                                if showRelatedArticles {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
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
                        viewModel.showShareSheet(selectedLanguage: selectedLanguage)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    
                    // Кнопка избранного
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorite ? .yellow : .primary)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showTextSizePanel) {
            TextSizeSettingsPanel()
                .environmentObject(AppContainer.shared)
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
