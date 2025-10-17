//
//  ArticleLibraryViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//
//
//  ArticleLibraryViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 14.10.25.
//

import Foundation

@MainActor
public final class ArticleLibraryViewModel: ObservableObject {
    @Published public private(set) var articles: [ArticleMetadata] = []

    public struct ArticleMetadata: Identifiable, Hashable {
        public let id: UUID
        public let url: URL
        public let title: String
        public let modified: Date

        public init(id: UUID = UUID(), url: URL, title: String, modified: Date) {
            self.id = id
            self.url = url
            self.title = title
            self.modified = modified
        }
    }

    public init() {
        refreshLibrary()
    }

    public func refreshLibrary() {
        articles.removeAll()
        let fm = FileManager.default
        guard let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        if let files = try? fm.contentsOfDirectory(
            at: docsURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) {
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

    public func deleteArticle(at offsets: IndexSet) {
        for idx in offsets {
            let article = articles[idx]
            try? FileManager.default.removeItem(at: article.url)
        }
        refreshLibrary()
    }
}
