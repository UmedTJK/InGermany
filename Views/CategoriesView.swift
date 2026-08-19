//
//  CategoriesView.swift
//  InGermany
//

import SwiftUI

/// Displays a list of article categories as a grid with 3 columns.
struct CategoriesView: View {

    @StateObject private var viewModel: CategoriesViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var localizationManager: LocalizationManager

    private let makeRowViewModel: (Article) -> ArticleRowViewModel
    private let makeDetailViewModel: (Article, [Article]) -> ArticleDetailViewModel

    // Grid layout: 3 columns with adaptive sizing
    private let columns = [
        GridItem(.flexible(), spacing: DS.Spacing.m),
        GridItem(.flexible(), spacing: DS.Spacing.m),
        GridItem(.flexible(), spacing: DS.Spacing.m),
        GridItem(.flexible(), spacing: DS.Spacing.m)
    ]

    init(
        viewModel: CategoriesViewModel,
        makeRowViewModel: @escaping (Article) -> ArticleRowViewModel,
        makeDetailViewModel: @escaping (Article, [Article]) -> ArticleDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeRowViewModel = makeRowViewModel
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: DS.Spacing.m) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(value: category) {
                            CategoryGridCard(
                                category: category,
                                language: selectedLanguage,
                                localizationManager: localizationManager
                            )
                        }
                        .buttonStyle(.plain)
                        .cardPressFeedback()
                    }
                }
                .padding(.horizontal, DS.Spacing.contentInset)
                .padding(.top, DS.Spacing.section)
                .padding(.bottom, DS.Spacing.section)
            }
            .scrollIndicators(.hidden)
            .background(DS.Color.background)
            .navigationTitle(t("tab_categories"))
            .task {
                await viewModel.load()
            }
            .navigationDestination(for: Category.self) { category in
                ArticlesByCategoryView(
                    category: category,
                    articles: viewModel.articles(for: category.id),
                    localizationManager: localizationManager,
                    articleRowFactory: makeRowViewModel,
                    articleDetailFactory: { article, allArticles in
                        makeDetailViewModel(article, allArticles)
                    }
                )
            }
        }
    }

    /// Provides localized strings for UI elements.
    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Category Grid Card

struct CategoryGridCard: View {
    let category: Category
    let language: String
    let localizationManager: LocalizationManager

    var body: some View {
        VStack(spacing: DS.Spacing.s) {
            // Icon with colored background
            ZStack {
                RoundedRectangle(cornerRadius: DS.Radius.card)
                    .fill(Color(hex: category.colorHex) ?? .blue)
                    .frame(width: 60, height: 60)

                Image(systemName: category.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }
            .accessibilityHidden(true)

            // Category name
            Text(category.localizedName(for: language))
                .font(.callout)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(DS.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.l)
        .padding(.horizontal, DS.Spacing.s)
        .cardContainer(.standard(useMaterial: true))
        .aspectRatio(1.0, contentMode: .fit) // Makes it square
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(category.localizedName(for: language)))
        .accessibilityHint(Text(localizationManager.getTranslation(key: "a11y_open_category_hint", language: language)))
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    CategoriesView(
        viewModel: container.makeCategoriesViewModel(),
        makeRowViewModel: container.makeArticleRowViewModel,
        makeDetailViewModel: { article, all in
            container.makeArticleDetailViewModel(article: article, allArticles: all)
        }
    )
    .environmentObject(container.localizationManager)
}
