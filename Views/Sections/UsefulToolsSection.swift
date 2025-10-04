//
//  UsefulToolsSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

/// A view that displays a section with useful tool cards for navigation, PDF viewing, and random article selection.
struct UsefulToolsSection: View {
    /// An array of articles used to select a random article.
    let articles: [Article]
    /// Closure called when a random article is selected.
    let onRandomArticleSelected: (Article) -> Void

    /// The content and behavior of the UsefulToolsSection view.
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.getTranslation(key: "Полезные инструменты", language: "ru"))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    /// Navigation link to the Map view.
                    NavigationLink(destination: MapView()) {
                        ToolCard(title: "Карта", systemImage: "map", color: .blue)
                    }

                    /// Navigation link to the PDF viewer with sample documents.
                    NavigationLink(destination: PDFViewer(fileName: "sample")) {
                        ToolCard(title: "PDF Документы", systemImage: "doc.richtext", color: .green)
                    }

                    /// Button to select and display a random article.
                    Button {
                        if let random = articles.randomElement() {
                            onRandomArticleSelected(random)
                        }
                    } label: {
                        ToolCard(title: "Случайная статья", systemImage: "shuffle", color: .orange)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
