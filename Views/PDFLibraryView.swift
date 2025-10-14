//
//  PDFLibraryView.swift
//  InGermany
//
//  Created by SUM TJK on 14.10.25.
//
//
//  PDFLibraryView.swift
//  InGermany
//
//  Created by  on 14.10.2025.
//

import SwiftUI

struct PDFLibraryView: View {
    @EnvironmentObject var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    @ObservedObject var viewModel: PDFLibraryViewModel

    var body: some View {
        List(viewModel.items) { item in
            NavigationLink {
                PDFViewer(fileName: item.fileName)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.title(for: item, language: selectedLanguage))
                        .font(.headline)
                    Text(viewModel.description(for: item, language: selectedLanguage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(t("tool_pdf_docs"))
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

