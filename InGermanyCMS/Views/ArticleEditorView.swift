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
                    .frame(width: 300)
                
                Divider()
                
                // Редактор выбранного блока
                blockEditorView
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(document.title)
        .onAppear {
            print("🔄 ArticleEditorView загружен с \(viewModel.blocks.count) блоками")
        }
        .sheet(isPresented: $viewModel.showBlockPicker) {
            NavigationStack {
                BlockPickerView { blockType in
                    viewModel.addBlock(blockType)
                    viewModel.showBlockPicker = false
                }
                .navigationTitle("Выберите тип блока")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") {
                            viewModel.showBlockPicker = false
                        }
                    }
                }
            }
            .frame(width: 400, height: 500)
        }
    }
    
    // MARK: - Компоненты интерфейса
    
    private var editorToolbar: some View {
        HStack {
            Button(action: {
                viewModel.showBlockPicker = true
            }) {
                Label("Добавить блок", systemImage: "plus")
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
        VStack {
            Text("Блоки статьи")
                .font(.headline)
                .padding()
            
            if viewModel.blocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Нет блоков")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Добавьте первый блок чтобы начать")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
        }
    }
    
    private var blockEditorView: some View {
        VStack {
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
                emptyEditorView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyEditorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cursorarrow.rays")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Выберите блок для редактирования")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Выберите блок из списка слева чтобы начать редактирование")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Вспомогательные View

struct BlockRowView: View {
    let block: ArticleBlock
    
    var body: some View {
        HStack {
            Image(systemName: blockTypeIcon)
                .foregroundColor(blockTypeColor)
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(block.type.rawValue.capitalized)
                    .font(.headline)
                if !block.content.isEmpty {
                    Text(block.content.prefix(30) + (block.content.count > 30 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
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
    
    private var blockTypeColor: Color {
        switch block.type {
        case .info: return .blue
        case .warning: return .orange
        case .tip: return .green
        case .quote: return .purple
        default: return .primary
        }
    }
}
