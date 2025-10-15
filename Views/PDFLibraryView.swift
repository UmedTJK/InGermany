//
//  PDFLibraryView.swift
//  InGermany
//
//  Created by SUM TJK on 14.10.25.
//

import SwiftUI

struct PDFLibraryView: View {
    @EnvironmentObject var appContainer: AppContainer
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    @ObservedObject var viewModel: PDFLibraryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        PDFViewer(fileName: item.fileName)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "doc.richtext")
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(viewModel.title(for: item, language: selectedLanguage))
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(viewModel.description(for: item, language: selectedLanguage))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle(t("tool_pdf_docs"))
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
