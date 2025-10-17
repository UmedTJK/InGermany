//
//  ContentView.swift
//  InGermanyCMS
//
//  Created by SUM TJK on 17.10.25.
//

import SwiftUI
import ArticleKit

struct ContentView: View {
    @StateObject private var libraryVM = ArticleLibraryViewModel()
    @State private var selectedArticle: ArticleLibraryViewModel.ArticleMetadata?
    
    var body: some View {
        NavigationSplitView {
            // Боковая панель - библиотека статей
            ArticleLibraryView(
                viewModel: libraryVM,
                onOpen: { url in
                    selectedArticle = libraryVM.articles.first { $0.url == url }
                }
            )
        } detail: {
            // Детальная панель
            if let article = selectedArticle {
                VStack {
                    Text(article.title)
                        .font(.title)
                    Text("URL: \(article.url.path)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .navigationTitle("Редактор")
            } else {
                DemoArticleView()
                    .navigationTitle("Демо статья")
            }
        }
    }
}
