//
//  RelatedArticlesView.swift
//  InGermany
//

import SwiftUI

struct RelatedArticlesView: View {
    let currentArticle: Article
    let favoritesManager: FavoritesManager
    let articles: [Article]

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    private var related: [Article] {
        let base = articles.filter { $0.id != currentArticle.id }
        let sameCategory = base.filter { $0.categoryId == currentArticle.categoryId }
        let byTags = base.filter { !$0.tags.isEmpty && !Set($0.tags).isDisjoint(with: currentArticle.tags) }
        let merged = Array(Set(sameCategory + byTags))
        return Array(merged.prefix(5))
    }

    var body: some View {
        if !related.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationManager.shared.translate("RelatedArticles"))
                    .font(.headline)

                ForEach(related, id: \.id) { item in
                    NavigationLink(
                        destination: ArticleView(
                            article: item,
                            allArticles: articles,              // ✅ теперь всё передаётся
                            favoritesManager: favoritesManager
                        )
                    ) {
                        HStack(alignment: .top, spacing: 12) {
                            Image("Logo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                                .clipped()

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.localizedTitle(for: selectedLanguage))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)

                                if let _ = item.createdAt {
                                    Text(item.formattedCreatedDate(for: selectedLanguage))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: favoritesManager.isFavorite(article: item) ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.top, 16)
        }
    }
}
