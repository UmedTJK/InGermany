//
//  ArticleLibraryViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.


import Foundation

@MainActor
final class ArticleLibraryViewModel: ObservableObject {
    @Published var articles: [ArticleMetadata] = []

    struct ArticleMetadata: Identifiable, Hashable {
        let id = UUID()
        let url: URL
        let title: String
        let modified: Date
    }

    init() {
        refreshLibrary()
    }

    func refreshLibrary() {
        articles.removeAll()
        let fm = FileManager.default
        guard let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        if let files = try? fm.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles]) {
            for url in files where url.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: url)
                    let doc = try JSONDecoder().decode(ArticleDocument.self, from: data)
                    let attrs = try url.resourceValues(forKeys: [.contentModificationDateKey])
                    let modified = attrs.contentModificationDate ?? Date()
                    let meta = ArticleMetadata(url: url, title: doc.title, modified: modified)
                    articles.append(meta)
                } catch {
                    print("⚠️ Failed to load \(url.lastPathComponent): \(error)")
                }
            }
        }

        articles.sort { $0.modified > $1.modified }
    }

    func deleteArticle(at offsets: IndexSet) {
        for idx in offsets {
            let article = articles[idx]
            try? FileManager.default.removeItem(at: article.url)
        }
        refreshLibrary()
    }
}

