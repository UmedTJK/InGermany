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

    @State private var appearedItems: Set<UUID> = []
    @State private var didAppear = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        PDFViewer(fileName: item.fileName)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            switch PDFThumbnailGenerator.generate(for: item.fileName) {
                            case .thumbnail(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 70)
                                    .cornerRadius(6)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .scaleEffect(0.95)

                            case .fallback(let icon):
                                icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 70)
                                    .foregroundColor(.red)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .shimmer()
                                    .scaleEffect(0.9)
                            }

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
                        // Анимация появления
                        .opacity(appearedItems.contains(item.id) ? 1 : 0)
                        .offset(y: appearedItems.contains(item.id) ? 0 : 20)
                        .onAppear {
                            let idx = viewModel.items.firstIndex(of: item) ?? 0
                            if !didAppear {
                                // каскад при первом открытии
                                let delay = Double(idx) * 0.12
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    appearedItems.insert(item.id)
                                }
                            } else {
                                // обычное появление при скролле
                                appearedItems.insert(item.id)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle(t("tool_pdf_docs"))
        .onAppear { didAppear = true }
        // Анимация привязана к изменению appearedItems (без withAnimation)
        .animation(.easeOut(duration: 0.6), value: appearedItems)
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}
