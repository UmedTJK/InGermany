//
//  UsefulToolsSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

struct UsefulToolsSection: View {
    let articles: [Article]
    let onRandomArticleSelected: (Article) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.getTranslation(key: "Полезные инструменты", language: "ru"))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    NavigationLink(destination: MapView()) {
                        ToolCard(title: "Карта", systemImage: "map", color: .blue)
                    }

                    NavigationLink(destination: PDFViewer(fileName: "sample")) {
                        ToolCard(title: "PDF Документы", systemImage: "doc.richtext", color: .green)
                    }

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

