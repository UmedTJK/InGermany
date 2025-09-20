//
//  ArticleMetaView.swift
//  InGermany
//

import SwiftUI

struct ArticleMetaView: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var categoriesStore: CategoriesStore

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                // 🔹 Категория
                if let category = categoriesStore.category(for: article.categoryId) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: category.colorHex) ?? .blue)
                            .frame(width: 14, height: 14)

                        Text(category.localizedName(for: selectedLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // 🔹 Дата (относительная или абсолютная)
                if let createdAt = article.createdAt {
                    let isRecent = Date().timeIntervalSince(createdAt) < 7 * 24 * 60 * 60
                    Text(
                        isRecent
                        ? article.relativeCreatedDate(for: selectedLanguage)
                        : article.formattedCreatedDate(for: selectedLanguage)
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                Spacer(minLength: 8)

                // 🔹 Бейджи
                if article.isNew {
                    Text("NEW")
                        .font(.caption2).bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                } else if article.isUpdatedRecently {
                    Text("UPDATED")
                        .font(.caption2).bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(6)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ArticleMetaView(article: Article.sampleArticle)
        .environmentObject(CategoriesStore.shared)
        .padding()
}
#endif
