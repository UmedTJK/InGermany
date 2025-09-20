//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 🔹 Заголовок
                Text(article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()

                // 🔹 Метаданные
                ArticleMetaView(article: article)

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

                // 🔹 Контент
                Text(article.localizedContent(for: selectedLanguage))
                    .font(.body)
                    .foregroundColor(.primary)

                // 🔹 Экспорт в PDF
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

                // 🔹 Открытие PDF
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
