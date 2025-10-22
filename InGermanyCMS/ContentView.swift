import SwiftUI
import ArticleKit

struct ContentView: View {
    @StateObject private var libraryVM = ArticleLibraryViewModel()
    @State private var selectedView: AppView? = .library
    
    enum AppView: Hashable {
        case library, demo, editor(ArticleDocument)
    }
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
    }
    
    private var sidebar: some View {
        List(selection: $selectedView) {
            Section("Articles") {
                Text("Article Library")
                    .tag(AppView.library)
                Text("Demo Article")
                    .tag(AppView.demo)
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("InGermany CMS")
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedView {
        case .library:
            ArticleLibraryView(viewModel: libraryVM) { document in
                selectedView = .editor(document)
            }
        case .demo:
            DemoArticleView()
        case .editor(let document):
            ArticleEditorView(document: document)
        case nil:
            Text("Select a view from the sidebar")
        }
    }
}
