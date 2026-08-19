//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var viewModel: HomeViewModel
    private let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    private let makeDataService: () -> DataServiceProtocol
    private let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    private let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel
    private let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView
    private let localizationManager: LocalizationManager

    // ✅ Колбэк для переключения на вкладку поиска
    var onSearchTapped: () -> Void

    init(
        viewModelFactory: @escaping () -> HomeViewModel,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol,
        makeArticleRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeArticleDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel,
        makeArticleDetailView: @escaping (Article, [Article]) -> ArticleDetailView,
        localizationManager: LocalizationManager,
        onSearchTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModelFactory())
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
        self.makeArticleRowViewModel = makeArticleRowViewModel
        self.makeArticleDetailViewModel = makeArticleDetailViewModel
        self.makeArticleDetailView = makeArticleDetailView
        self.localizationManager = localizationManager
        self.onSearchTapped = onSearchTapped
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.section) {

                    // ✅ 1. Поисковая строка (вызывает onSearchTapped)
                    SearchHomeTriggerView(
                        onTap: onSearchTapped
                    )
                    .padding(.horizontal, DS.Spacing.contentInset)

                    // ✅ 2. ВЕРНУЛИ БАННЕР С КАРТИНКОЙ
                    HeroBannerView()

                    // ✅ 3. ВЕРНУЛИ ТЕКСТОВЫЙ БЛОК
                    AppTitleSection()

                    // ✅ 4. Остальной контент
                    if viewModel.isLoading {
                        SkeletonHomeView()
                    } else {
                        if !viewModel.articles.isEmpty {
                            RecentlyReadSection(
                                articles: viewModel.articles,
                                favoritesManager: viewModel.favoritesManager,
                                readingStatsManager: viewModel.readingStatsManager,
                                makeRowViewModel: makeArticleRowViewModel,
                                makeDetailViewModel: { article, all in
                                    makeArticleDetailViewModel(article, all)
                                }
                            )
                        }

                        let hasFavorites = viewModel.articles.contains {
                            viewModel.favoritesManager.isFavorite($0.id)
                        }

                        if hasFavorites {
                            FavoritesSection(
                                articles: viewModel.articles,
                                favoritesManager: viewModel.favoritesManager,
                                makeRowViewModel: makeArticleRowViewModel,
                                makeDetailViewModel: { article, all in
                                    makeArticleDetailViewModel(article, all)
                                }
                            )
                        }

                        ForEach(viewModel.allCategories, id: \.id) { category in
                            if let categoryArticles = viewModel.articlesByCategory[category.id],
                               !categoryArticles.isEmpty {
                                CategorySection(
                                    category: category,
                                    articles: categoryArticles,
                                    favoritesManager: viewModel.favoritesManager,
                                    language: selectedLanguage,
                                    makeRowViewModel: makeArticleRowViewModel,
                                    makeDetailView: { article, all in
                                        makeArticleDetailView(article, all)
                                    }
                                )
                            }
                        }

                        SectionHeader(
                            title: String(localized: "home.all_articles"),
                            actionTitle: nil,
                            action: nil
                        )
                        .padding(.horizontal, DS.Spacing.contentInset)

                        AllArticlesSection(
                            articles: viewModel.articles,
                            favoritesManager: viewModel.favoritesManager,
                            makeRowViewModel: makeArticleRowViewModel,
                            makeDetailViewModel: { article, all in
                                makeArticleDetailViewModel(article, all)
                            }
                        )
                    }
                }
                .padding(.bottom, DS.Spacing.section)
            }
            .scrollIndicators(.hidden)
            .refreshable { await viewModel.refreshData() }
            .background(DS.Color.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.isShowingRandomArticle) {
                if let article = viewModel.randomArticle {
                    ArticleDetailView(
                        viewModel: makeArticleDetailViewModel(article, viewModel.articles),
                        localizationManager: localizationManager,
                        articleRowFactory: makeArticleRowViewModel
                    )
                }
            }
            .task { await viewModel.loadData() }
        }
    }
}

// MARK: - Home Search Trigger (Верхняя широкая зона поиска)

struct SearchHomeTriggerView: View {
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onTap()
        }) {
            HStack(spacing: DS.Spacing.m) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                Text("Поиск статей, категорий и тем...")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue.opacity(0.7))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, DS.Spacing.m)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hero Banner View

struct HeroBannerView: View {
    var body: some View {
        GeometryReader { geo in
            Image("homeBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: 280)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.1),
                            Color.black.opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask(
                    RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                )
        }
        .frame(height: 280)
        .padding(.horizontal, 15)
    }
}

// MARK: - App's Title Section

struct AppTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("InGermany")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Справочник по Германии 2026: миграция, работа, учёба, жизнь и бюрократия")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.black.opacity(0.25)
                .blur(radius: 2)
        )
        .cornerRadius(20)
        .padding(.horizontal, 15)
    }
}


// MARK: - Skeleton Loading

struct SkeletonHomeView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            // Skeleton Section Header
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DS.Color.secondarySurface)
                    .frame(width: 150, height: 20)
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.contentInset)
            
            // Skeleton Articles
            VStack(spacing: DS.Spacing.m) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .fill(DS.Color.secondarySurface)
                        .frame(height: 120)
                        .shimmering()
                }
            }
            .padding(.horizontal, DS.Spacing.contentInset)
        }
    }
}

// MARK: - Shimmer Extension

extension View {
    func shimmering() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.3), location: 0.3),
                            .init(color: .clear, location: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    HomeView(
        viewModelFactory: { container.makeHomeViewModel() },
        makePDFLibraryViewModel: container.makePDFLibraryViewModel,
        makeDataService: { container.dataService },
        makeArticleRowViewModel: container.makeArticleRowViewModel,
        makeArticleDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        },
        makeArticleDetailView: { article, all in
            container.makeArticleDetailView(article: article, allArticles: all)
        },
        localizationManager: container.localizationManager,
        onSearchTapped: {}
    )
}
