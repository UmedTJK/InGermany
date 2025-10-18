import SwiftUI
import ArticleKit

public struct ArticleLibraryView: View {
    @StateObject private var viewModel: ArticleLibraryViewModel
    let onOpenArticle: (ArticleDocument) -> Void

    public init(viewModel: ArticleLibraryViewModel, onOpenArticle: @escaping (ArticleDocument) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenArticle = onOpenArticle
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
                            loadArticleDocument(from: article.url) { document in
                                onOpenArticle(document)
                            }
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
                
                Button {
                    // Создаем новую статью
                    if let newArticle = viewModel.createNewArticle() {
                        let newDocument = ArticleDocument(
                            title: newArticle.title,
                            sections: [],
                            url: newArticle.url
                        )
                        onOpenArticle(newDocument)
                    }
                } label: {
                    Label("New Article", systemImage: "plus")
                }
            }
        }
    }
    
    private func loadArticleDocument(from url: URL, completion: @escaping (ArticleDocument) -> Void) {
        do {
            let data = try Data(contentsOf: url)
            let document = try JSONDecoder().decode(ArticleDocument.self, from: data)
            completion(document)
        } catch {
            print("⚠️ Failed to load article document: \(error)")
            // Создаем пустой документ в случае ошибки
            let emptyDocument = ArticleDocument(
                title: "Untitled",
                sections: [],
                url: url
            )
            completion(emptyDocument)
        }
    }
}
