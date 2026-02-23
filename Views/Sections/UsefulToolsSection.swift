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

    private func toolLabel(title: String, systemImage: String, color: Color, hintKey: String) -> some View {
        ToolCard(
            title: title,
            systemImage: systemImage,
            color: color
        )
        .frame(minHeight: DS.Size.hitTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(t(hintKey)))
        .accessibilityAddTraits(.isButton)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            SectionHeader(title: t("section_useful_tools"))

            HorizontalCarousel {

                NavigationLink(destination: MapView(dataService: makeDataService())) {
                    toolLabel(
                        title: t("tool_map"),
                        systemImage: "map",
                        color: .blue,
                        hintKey: "a11y_open_map_hint"
                    )
                }
                .buttonStyle(.plain)
                .cardPressFeedback()

                NavigationLink(
                    destination: PDFLibraryView(
                        viewModel: makePDFLibraryViewModel()
                    )
                ) {
                    toolLabel(
                        title: t("tool_pdf_docs"),
                        systemImage: "doc.richtext",
                        color: .green,
                        hintKey: "a11y_open_pdf_library_hint"
                    )
                }
                .buttonStyle(.plain)
                .cardPressFeedback()

                Button {
                    if let random = articles.randomElement() {
                        onRandomArticleSelected(random)
                    }
                } label: {
                    toolLabel(
                        title: t("tool_random_article"),
                        systemImage: "shuffle",
                        color: .orange,
                        hintKey: "a11y_open_random_article_hint"
                    )
                }
                .buttonStyle(.plain)
                .cardPressFeedback()
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
