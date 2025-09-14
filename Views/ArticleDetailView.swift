//
//  ArticleDetailView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

//
//
//  ArticleDetailView.swift
//  InGermany
//

//
//  ArticleDetailView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//
//
//  ArticleDetailView.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var favoritesManager: FavoritesManager
    let selectedLanguage: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .fontWeight(.bold)
                
                // Основной текст
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Теги
                if !article.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(article.tags, id: \.self) { tag in
                                NavigationLink {
                                    ArticlesByTagView(
                                        tag: tag,
                                        articles: DataService.shared.loadArticles(),
                                        favoritesManager: favoritesManager,
                                        selectedLanguage: selectedLanguage
                                    )
                                } label: {
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.15))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Материалы по теме
                let relatedArticles = DataService.shared.loadArticles().filter { other in
                    other.id != article.id &&
                    !Set(other.tags).isDisjoint(with: article.tags)
                }
                
                if !relatedArticles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Материалы по данной теме")
                            .font(.headline)
                            .padding(.top, 12)
                        
                        ForEach(relatedArticles.prefix(3)) { related in
                            NavigationLink {
                                ArticleDetailView(
                                    article: related,
                                    favoritesManager: favoritesManager,
                                    selectedLanguage: selectedLanguage
                                )
                            } label: {
                                ArticleRow(article: related, favoritesManager: favoritesManager)
                            }
                        }
                    }
                }
                
                // Кнопки действий
                HStack {
                    Button {
                        favoritesManager.toggleFavorite(article: article)
                    } label: {
                        Label(
                            favoritesManager.isFavorite(article: article)
                            ? "Убрать из избранного"
                            : "В избранное",
                            systemImage: favoritesManager.isFavorite(article: article)
                            ? "heart.fill"
                            : "heart"
                        )
                    }
                    
                    Spacer()
                    
                    Button {
                        ShareService.shareArticle(article, language: selectedLanguage)
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle(article.localizedTitle(for: selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ArticleDetailView(
        article: Article.sampleArticle,
        favoritesManager: FavoritesManager(),
        selectedLanguage: "ru"
    )
}
