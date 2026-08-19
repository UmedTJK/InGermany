//
//  HomeView.swift
//  InGermany
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    private let makeDataService: () -> DataServiceProtocol
    private let makeArticleRowViewModel: (Article) -> ArticleRowViewModel
    private let makeArticleDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel
    private let makeArticleDetailView: (Article, [Article]) -> ArticleDetailView
    private let localizationManager: LocalizationManager

    init(
        viewModelFactory: @escaping () -> HomeViewModel,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol,
        makeArticleRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeArticleDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel,
        makeArticleDetailView: @escaping (Article, [Article]) -> ArticleDetailView,
        localizationManager: LocalizationManager
    ) {
        _viewModel = StateObject(wrappedValue: viewModelFactory())
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
        self.makeArticleRowViewModel = makeArticleRowViewModel
        self.makeArticleDetailViewModel = makeArticleDetailViewModel
        self.makeArticleDetailView = makeArticleDetailView
        self.localizationManager = localizationManager
    }

    /// Для превью и тестов
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makePDFLibraryViewModel = { fatalError("Not implemented") }
        self.makeDataService = { fatalError("Not implemented") }
        self.makeArticleRowViewModel = { _ in fatalError("Not implemented") }
        self.makeArticleDetailViewModel = { _, _ in fatalError("Not implemented") }
        self.makeArticleDetailView = { _, _ in fatalError("Not implemented") }
        self.localizationManager = LocalizationManager()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.section) {
                    
                    // MARK: - Hero Header
                    HeroHeaderView(
                        userName: "🇩🇪 \(String(localized: "home.welcome"))",
                        articlesCount: viewModel.articles.count
                    )
                    
                    if viewModel.isLoading {
                        // MARK: - Skeleton Loading
                        SkeletonHomeView()
                    } else {
                        // MARK: - Continue Reading
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
                        
                        // MARK: - Favorites
                        let hasFavorites = viewModel.articles.contains { article in
                            viewModel.favoritesManager.isFavorite(article.id)
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
                        
                        // MARK: - All Categories
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
                        
                        // MARK: - All Articles
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
                .padding(.top, DS.Spacing.section)
                .padding(.bottom, DS.Spacing.section)
            }
            .scrollIndicators(.hidden)
            .refreshable { await viewModel.refreshData() }
            .background(DS.Color.background)
            .navigationTitle("app.name")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.isShowingRandomArticle) {
                if let article = viewModel.randomArticle {
                    ArticleDetailView(
                        viewModel: makeArticleDetailViewModel(
                            article,
                            viewModel.articles
                        ),
                        localizationManager: localizationManager,
                        articleRowFactory: makeArticleRowViewModel
                    )
                }
            }
            .task { await viewModel.loadData() }
        }
    }
}

// MARK: - Hero Header

struct HeroHeaderView: View {
    let userName: String
    let articlesCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DS.Color.textPrimary)
                    
                    Text("\(articlesCount) \(String(localized: "home.articles_available"))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Аватар или иконка
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, DS.Spacing.contentInset)
        }
    }
}

// MARK: - Quick Actions Grid

struct QuickActionsGrid: View {
    let onRandom: () -> Void
    let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    let makeDataService: () -> DataServiceProtocol
    
    private let actions: [(title: String, icon: String, color: Color)] = [
        ("home.random", "dice", .purple),
        ("home.pdf_library", "doc.richtext", .blue),
        ("home.places", "map", .green),
    ]
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            // Случайная статья
            Button(action: onRandom) {
                QuickActionCard(
                    title: String(localized: "home.random"),
                    icon: "dice",
                    color: .purple
                )
            }
            .buttonStyle(.plain)
            
            // PDF Библиотека
            NavigationLink {
                PDFLibraryView(viewModel: makePDFLibraryViewModel())
            } label: {
                QuickActionCard(
                    title: String(localized: "home.pdf_library"),
                    icon: "doc.richtext",
                    color: .blue
                )
            }
            .buttonStyle(.plain)
            
            // Карта
            NavigationLink {
                MapView(dataService: makeDataService())
            } label: {
                QuickActionCard(
                    title: String(localized: "home.places"),
                    icon: "map",
                    color: .green
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        VStack(spacing: DS.Spacing.s) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(DS.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.m)
        .cardContainer(.standard(useMaterial: true))
        .scaleOnAppear()
        .cardPressFeedback()
    }
}

// MARK: - Category Carousel

struct CategoryCarousel: View {
    let categories: [Category]
    let language: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Text(String(localized: "home.popular_categories"))
                .font(.headline)
                .padding(.horizontal, DS.Spacing.contentInset)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.s) {
                    ForEach(categories.prefix(6), id: \.id) { category in
                        NavigationLink {
                            // TODO: Переход на категорию
                        } label: {
                            CategoryChip(
                                category: category,
                                language: language
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DS.Spacing.contentInset)
                .padding(.vertical, DS.Spacing.xs)
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: Category
    let language: String
    
    var body: some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: category.icon)
                .font(.caption)
                .foregroundStyle(Color(hex: category.colorHex) ?? .blue)
            
            Text(category.localizedName(for: language))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DS.Color.textPrimary)
        }
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.s)
        .background(DS.Color.secondarySurface.opacity(0.6))
        .cornerRadius(DS.Radius.chip)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.chip)
                .stroke(Color(hex: category.colorHex)?.opacity(0.3) ?? .clear, lineWidth: 1)
        )
    }
}

// MARK: - Skeleton Loading

struct SkeletonHomeView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            // Skeleton Quick Actions
            HStack(spacing: DS.Spacing.m) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DS.Radius.card)
                        .fill(DS.Color.secondarySurface)
                        .frame(height: 100)
                        .shimmering()
                }
            }
            .padding(.horizontal, DS.Spacing.contentInset)
            
            // Skeleton Categories
            HStack(spacing: DS.Spacing.s) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DS.Radius.chip)
                        .fill(DS.Color.secondarySurface)
                        .frame(width: 80, height: 36)
                        .shimmering()
                }
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
        localizationManager: container.localizationManager
    )
}
