//  ArticleLibraryView.swift
//  InGermany
//
//  Created by SUM TJK on 14.10.25.
//

import SwiftUI
import ArticleKit


public struct ArticleLibraryView: View {
    @StateObject private var viewModel: ArticleLibraryViewModel
    let onOpen: (URL) -> Void

    init(viewModel: ArticleLibraryViewModel, onOpen: @escaping (URL) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpen = onOpen
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.articles) { article in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(article.title.isEmpty ? "Untitled" : article.title)
                                .font(.headline)
                            Text(article.modified.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Open") {
                            onOpen(article.url)  // ✅ используем url из ArticleMetadata
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .onDelete(perform: viewModel.deleteArticle)
            }
            .navigationTitle("Article Library")
            .toolbar {
                Button {
                    viewModel.refreshLibrary()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
    }
}
