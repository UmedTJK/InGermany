//
//  UsefulToolsSection.swift
//  InGermany
//
//  Created by SUM TJK on 28.09.25.
//

import SwiftUI

struct UsefulToolsSection: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    let articles: [Article]
    let onRandomArticleSelected: (Article) -> Void
    private let makePDFLibraryViewModel: () -> PDFLibraryViewModel
    private let makeDataService: () -> DataServiceProtocol
    
    init(
        articles: [Article],
        onRandomArticleSelected: @escaping (Article) -> Void,
        makePDFLibraryViewModel: @escaping () -> PDFLibraryViewModel,
        makeDataService: @escaping () -> DataServiceProtocol
    ) {
        self.articles = articles
        self.onRandomArticleSelected = onRandomArticleSelected
        self.makePDFLibraryViewModel = makePDFLibraryViewModel
        self.makeDataService = makeDataService
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            SectionHeader(title: t("section_useful_tools"))

            HorizontalCarousel {

                NavigationLink(destination: MapView(dataService: makeDataService())) {
                    ToolCard(
                        title: t("tool_map"),
                        systemImage: "map",
                        color: .blue
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(
                    destination: PDFLibraryView(
                        viewModel: makePDFLibraryViewModel()
                    )
                ) {
                    ToolCard(
                        title: t("tool_pdf_docs"),
                        systemImage: "doc.richtext",
                        color: .green
                    )
                }
                .buttonStyle(.plain)

                Button {
                    if let random = articles.randomElement() {
                        onRandomArticleSelected(random)
                    }
                } label: {
                    ToolCard(
                        title: t("tool_random_article"),
                        systemImage: "shuffle",
                        color: .orange
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(
            key: key,
            language: selectedLanguage
        )
    }
}
