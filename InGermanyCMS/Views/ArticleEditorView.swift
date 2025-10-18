import SwiftUI
import ArticleKit

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var selectedBlockId: UUID?
    
    let document: ArticleDocument
    
    init(document: ArticleDocument) {
        self.document = document
        _viewModel = StateObject(wrappedValue: ArticleEditorViewModel(document: document))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель инструментов
            editorToolbar
            
            // Основной контент
            HStack(spacing: 0) {
                // Список блоков
                blocksListView
                    .frame(width: 400)
                
                // Редактор выбранного блока
                blockEditorView
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(document.title)
        .sheet(isPresented: $viewModel.showBlockPicker) {
            BlockPickerView { blockType in
                viewModel.addBlock(blockType)
            }
        }
    }
    
    // MARK: - Компоненты интерфейса
    
    private var editorToolbar: some View {
        HStack {
            Button("Добавить блок") {
                viewModel.showBlockPicker = true
            }
            
            Spacer()
            
            Button("Сохранить") {
                viewModel.saveDocument()
            }
            
            Button("Предпросмотр") {
                viewModel.togglePreview()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var blocksListView: some View {
        List(selection: $selectedBlockId) {
            ForEach(viewModel.blocks) { block in
                BlockRowView(block: block)
                    .tag(block.id)
                    .contextMenu {
                        Button("Удалить", role: .destructive) {
                            viewModel.removeBlock(block)
                        }
                    }
            }
            .onMove { indices, newOffset in
                viewModel.moveBlocks(from: indices, to: newOffset)
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    private var blockEditorView: some View {
        ScrollView {
            if let selectedId = selectedBlockId,
               let selectedBlockIndex = viewModel.blocks.firstIndex(where: { $0.id == selectedId }) {
                BlockEditor(
                    block: Binding(
                        get: { viewModel.blocks[selectedBlockIndex] },
                        set: { viewModel.blocks[selectedBlockIndex] = $0 }
                    )
                )
                .padding()
            } else {
                Text("Выберите блок для редактирования")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Вспомогательные View

struct BlockRowView: View {
    let block: ArticleBlock
    
    var body: some View {
        HStack {
            Image(systemName: blockTypeIcon)
            Text(block.type.rawValue.capitalized)
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var blockTypeIcon: String {
        switch block.type {
        case .paragraph: return "text.alignleft"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .tip: return "lightbulb"
        case .quote: return "quote.opening"
        case .checklist: return "checklist"
        case .faq: return "questionmark.circle"
        case .list: return "list.bullet"
        case .links: return "link"
        case .image: return "photo"
        }
    }
}
