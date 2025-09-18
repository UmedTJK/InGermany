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

                // 🔹 Заглавное изображение (временно — логотип проекта)
                Image("Logo")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.bottom, 4)

                // 🔹 Заголовок статьи
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                // 🔹 Теги
                if !article.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(article.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // 🔹 Контент статьи
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .foregroundColor(.primary)

                // 🔹 Кнопка экспорта в PDF
                Button {
                    ExportToPDF.export(
                        title: article.localizedTitle(for: selectedLanguage),
                        content: article.localizedContent(for: selectedLanguage),
                        fileName: article.localizedTitle(for: selectedLanguage)
                            .replacingOccurrences(of: " ", with: "_")
                    )
                } label: {
                    Label("Экспорт в PDF", systemImage: "square.and.arrow.down")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }

                // 🔹 Кнопка "Открыть PDF", если файл указан
                if let pdfFileName = article.pdfFileName {
                    NavigationLink(destination: PDFViewer(fileName: pdfFileName)) {
                        Label("Открыть PDF", systemImage: "doc.richtext")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Статья")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                favoritesManager.toggleFavorite(id: article.id)
            } label: {
                Image(systemName: favoritesManager.isFavorite(id: article.id) ? "heart.fill" : "heart")
            }
        }
    }
}
