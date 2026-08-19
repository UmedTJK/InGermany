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

    @Binding var selectedTab: Int

    init(
        viewModelFactory: @escaping () -> HomeViewModel,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol,
        makeArticleRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeArticleDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel,
        makeArticleDetailView: @escaping (Article, [Article]) -> ArticleDetailView,
        localizationManager: LocalizationManager,
        selectedTab: Binding<Int>
    ) {
        _viewModel = StateObject(wrappedValue: viewModelFactory())
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
        self.makeArticleRowViewModel = makeArticleRowViewModel
        self.makeArticleDetailViewModel = makeArticleDetailViewModel
        self.makeArticleDetailView = makeArticleDetailView
        self.localizationManager = localizationManager
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.section) {
                    
                    // 1. Поисковая строка
                    SearchHomeTriggerView(
                        onTap: { selectedTab = 2 }
                    )
                    .padding(.horizontal, DS.Spacing.contentInset)
                    
                    // 2. Баннер (с текстом внутри)
                    HeroBannerView()
                    
                    // 3. Список всех статей (просто друг под другом)
                    if viewModel.isLoading {
                        SkeletonHomeView()
                    } else {
                        VStack(spacing: DS.Spacing.m) {
                            ForEach(viewModel.articles, id: \.id) { article in
                                NavigationLink {
                                    ArticleDetailView(
                                        viewModel: makeArticleDetailViewModel(article, viewModel.articles),
                                        localizationManager: localizationManager,
                                        articleRowFactory: makeArticleRowViewModel
                                    )
                                } label: {
                                    ArticleRow(viewModel: makeArticleRowViewModel(article))
                                        .padding(DS.Spacing.m)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .clipShape(
                                            RoundedCorner(radius: 16, corners: .allCorners)
                                        )
                                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                                        .padding(.horizontal, DS.Spacing.contentInset)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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

// MARK: - Home Search Trigger
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

// MARK: - Hero Banner View (С текстом внутри)
struct HeroBannerView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
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
                .padding(.bottom, 20)
            }
        }
        .frame(height: 280)
        .padding(.horizontal, 15)
    }
}

// MARK: - Skeleton Loading
struct SkeletonHomeView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.m) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DS.Color.secondarySurface)
                    .frame(width: 150, height: 40)
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.contentInset)
            
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

// MARK: - Shimmer
extension View {
    func shimmering() -> some View {
        modifier(ShimmerEffect())
    }
}

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
        selectedTab: .constant(0)
    )
}
