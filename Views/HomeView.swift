//
//  HomeView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject var favoritesManager: FavoritesManager
    let articles: [Article]
    
    // Состояние для управления навигацией к случайной статье
    @State private var isShowingRandomArticle = false
    @State private var randomArticle: Article?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 🔹 Раздел с картой и случайной статьей
                    Section {
                        VStack(spacing: 12) {
                            // Карта локаций
                            NavigationLink {
                                MapView()
                            } label: {
                                HStack {
                                    Image(systemName: "map")
                                        .foregroundColor(.blue)
                                    Text("Карта локаций")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                            }
                            
                            // Кнопка "Случайная статья"
                            Button(action: {
                                randomArticle = articles.randomElement()
                                isShowingRandomArticle = true
                            }) {
                                HStack {
                                    Image(systemName: "dice.fill")
                                        .foregroundColor(.green)
                                    Text("Случайная статья")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        Text("Полезное")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }

                    // 🔹 Избранные статьи - горизонтальный скролл карточек
                    let favorites = favoritesManager.favoriteArticles(from: articles)
                    if !favorites.isEmpty {
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(favorites) { article in
                                        NavigationLink(
                                            destination: ArticleView(
                                                article: article,
                                                allArticles: articles,
                                                favoritesManager: favoritesManager
                                            )
                                        ) {
                                            FavoriteCard(
                                                article: article,
                                                favoritesManager: favoritesManager
                                            )
                                        }
                                        .buttonStyle(AppleCardButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        } header: {
                            HStack {
                                Text("\(getTranslation(key: "Избранное", language: selectedLanguage)) (\(favorites.count))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                NavigationLink("Все") {
                                    FavoritesView(
                                        favoritesManager: favoritesManager,
                                        articles: articles
                                    )
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // 🔹 Все статьи - обычный список
                    Section {
                        LazyVStack(spacing: 12) {
                            ForEach(articles) { article in
                                NavigationLink(
                                    destination: ArticleView(
                                        article: article,
                                        allArticles: articles,
                                        favoritesManager: favoritesManager
                                    )
                                ) {
                                    ArticleRow(
                                        article: article,
                                        favoritesManager: favoritesManager
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        Text("\(getTranslation(key: "Все статьи", language: selectedLanguage)) (\(articles.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(getTranslation(key: "Главная", language: selectedLanguage))
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $isShowingRandomArticle) {
                Group {
                    if let randomArticle {
                        ArticleView(
                            article: randomArticle,
                            allArticles: articles,
                            favoritesManager: favoritesManager
                        )
                    }
                }
            }
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Главная": ["ru": "Главная", "en": "Home", "de": "Startseite", "tj": "Асосӣ"],
            "Избранное": ["ru": "Избранное", "en": "Favorites", "de": "Favoriten", "tj": "Интихобшуда"],
            "Все статьи": ["ru": "Все статьи", "en": "All Articles", "de": "Alle Artikel", "tj": "Ҳамаи мақолаҳо"],
            "Полезное": ["ru": "Полезное", "en": "Useful", "de": "Nützliches", "tj": "Муфид"]
        ]
        return translations[key]?[language] ?? key
    }
}

#Preview {
    HomeView(
        favoritesManager: FavoritesManager(),
        articles: DataService.shared.loadArticles()
    )
}
