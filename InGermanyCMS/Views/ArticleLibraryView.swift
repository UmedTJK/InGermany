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
            Group {
                if viewModel.articles.isEmpty {
                    emptyStateView
                } else {
                    articlesListView
                }
            }
            .navigationTitle("Article Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewArticle()
                    } label: {
                        Label("New Article", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.refreshLibrary()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Articles Yet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Create your first article to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create New Article") {
                createNewArticle()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var articlesListView: some View {
        List {
            ForEach(viewModel.articles) { article in
                articleRowView(article)
            }
            .onDelete(perform: viewModel.deleteArticle)
        }
    }
    
    private func articleRowView(_ article: ArticleLibraryViewModel.ArticleMetadata) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title.isEmpty ? "Untitled" : article.title)
                    .font(.headline)
                
                Text(article.modified.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Open") {
                loadAndOpenArticle(article)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
    
    private func createNewArticle() {
        if let newArticle = viewModel.createNewArticle() {
            let newDocument = ArticleDocument(
                title: newArticle.title,
                sections: [
                    ArticleSectionDTO(
                        type: "paragraph",
                        content: "Начните писать вашу статью здесь..."
                    )
                ],
                url: newArticle.url
            )
            onOpenArticle(newDocument)
        }
    }
    
    private func loadAndOpenArticle(_ article: ArticleLibraryViewModel.ArticleMetadata) {
        do {
            let data = try Data(contentsOf: article.url)
            let document = try JSONDecoder().decode(ArticleDocument.self, from: data)
            onOpenArticle(document)
        } catch {
            print("⚠️ Failed to load article: \(error)")
            // Создаем новый документ если не удалось загрузить
            let newDocument = ArticleDocument(
                title: article.title,
                sections: [],
                url: article.url
            )
            onOpenArticle(newDocument)
        }
    }
}
