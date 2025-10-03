//
//  FavoritesView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    @State private var searchText = ""
    
    private var filteredFavoriteArticles: [Article] {
        let favoriteArticles = viewModel.favoriteArticles
        if searchText.isEmpty {
            return favoriteArticles
        } else {
            return favoriteArticles.filter {
                $0.localizedTitle(for: selectedLanguage).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    init(viewModel: FavoritesViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AppContainer.shared.makeFavoritesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(getDataSourceColor())
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
                
                if viewModel.isLoading {
                    ProgressView("Загрузка избранного...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if filteredFavoriteArticles.isEmpty {
                        Text(getTranslation(key: "Нет избранных статей", language: selectedLanguage))
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        favoritesList
                    }
                }
            }
            .navigationTitle(getTranslation(key: "Избранное", language: selectedLanguage))
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: getTranslation(key: "Поиск в избранном", language: selectedLanguage))
            .task {
                await viewModel.loadFavorites()
            }
        }
    }
    
    // MARK: - Favorites List
    private var favoritesList: some View {
        List(filteredFavoriteArticles) { article in
            NavigationLink {
                ArticleDetailView(
                    article: article,
                    allArticles: viewModel.allArticles
                )
            } label: {
                ArticleRow(viewModel: ArticleRowViewModel(article: article))
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func getDataSourceColor() -> Color {
        switch viewModel.dataSource {
        case "network": return .green
        case "memory_cache": return .blue
        case "local": return .orange
        default: return .gray
        }
    }
    
    // MARK: - Translation
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Избранное": [
                "ru": "Избранное",
                "en": "Favorites",
                "de": "Favoriten",
                "tj": "Интихобшуда",
                "fa": "علاقه‌مندی‌ها",
                "ar": "المفضلة",
                "uk": "Вибране"
            ],
            "Нет избранных статей": [
                "ru": "Нет избранных статей",
                "en": "No favorite articles",
                "de": "Keine Favoriten",
                "tj": "Мақолаҳои интихобшуда нест",
                "fa": "هیچ مقاله مورد علاقه‌ای وجود ندارد",
                "ar": "لا توجد مقالات مفضلة",
                "uk": "Немає вибраних статей"
            ],
            "Поиск в избранном": [
                "ru": "Поиск в избранном",
                "en": "Search favorites",
                "de": "Favoriten durchsuchen",
                "tj": "Ҷустуҷӯ дар интихобшудаҳо",
                "fa": "جستجو در علاقه‌مندی‌ها",
                "ar": "بحث في المفضلة",
                "uk": "Пошук у вибраному"
            ]
        ]
        return translations[key]?[language] ?? key
    }

    }
