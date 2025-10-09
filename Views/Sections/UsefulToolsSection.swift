//
//  UsefulToolsSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//
import SwiftUI

struct UsefulToolsSection: View {
    @EnvironmentObject var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    let articles: [Article]
    let onRandomArticleSelected: (Article) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(t("section_useful_tools"))
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    NavigationLink(destination: MapView()) {
                        ToolCard(title: t("tool_map"), systemImage: "map", color: .blue)
                    }

                    NavigationLink(destination: PDFViewer(fileName: "sample")) {
                        ToolCard(title: t("tool_pdf_docs"), systemImage: "doc.richtext", color: .green)
                    }

                    Button {
                        if let random = articles.randomElement() {
                            onRandomArticleSelected(random)
                        }
                    } label: {
                        ToolCard(title: t("tool_random_article"), systemImage: "shuffle", color: .orange)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
