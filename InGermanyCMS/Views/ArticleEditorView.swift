import SwiftUI
import ArticleKit
import Combine

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var selectedBlockId: UUID?
    @State private var showPreview = true
    
    let document: ArticleDocument
    
    init(document: ArticleDocument) {
        self.document = document
        _viewModel = StateObject(wrappedValue: ArticleEditorViewModel(document: document))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            editorToolbar
            mainContentView
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
    
    // MARK: - Основной контент с Split View
    
    private var mainContentView: some View {
        Group {
            if showPreview {
                HSplitView {
                    editorPanel
                        .frame(minWidth: 300, maxWidth: .infinity)
                    previewPanel
                        .frame(minWidth: 300, maxWidth: .infinity)
                }
            } else {
                editorPanel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Панель редактора
    
    private var editorPanel: some View {
        HStack(spacing: 0) {
            blocksListView
                .frame(width: 280)
            
            Divider()
            
            blockEditorView
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Панель превью
    
    private var previewPanel: some View {
        VStack(spacing: 0) {
            previewHeader
            previewContent
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var previewHeader: some View {
        HStack {
            Text("Предпросмотр")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                viewModel.objectWillChange.send()
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Обновить предпросмотр")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var previewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(document.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ArticleRenderer(sections: viewModel.blocks.map { $0.toSectionDTO() })
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Компоненты интерфейса
    
    private var editorToolbar: some View {
        HStack {
            HStack {
                Button(action: {
                    viewModel.showBlockPicker = true
                }) {
                    Label("Добавить блок", systemImage: "plus")
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showPreview.toggle()
                    }
                }) {
                    Label(
                        showPreview ? "Скрыть превью" : "Показать превью",
                        systemImage: showPreview ? "eye.slash" : "eye"
                    )
                }
            }
            
            Spacer()
            
            HStack {
                statusIndicator
                
                Button("Сохранить") {
                    viewModel.saveDocument()
                }
                .disabled(!viewModel.hasUnsavedChanges)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }

    // Индикатор состояния
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            if viewModel.isSaving {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                Text("Сохранение...")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else if viewModel.hasUnsavedChanges {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.orange)
                Text("Не сохранено")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Сохранено")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSaving)
        .animation(.easeInOut(duration: 0.2), value: viewModel.hasUnsavedChanges)
    }

    // Список блоков
    private var blocksListView: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Блоки статьи")
                    .font(.headline)
                
                Text("\(viewModel.blocks.count) \(blockCountText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            if viewModel.blocks.isEmpty {
                emptyBlocksView
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
        .background(Color(NSColor.controlBackgroundColor))
    }

    // Счетчик блоков
    private var blockCountText: String {
        let count = viewModel.blocks.count
        let remainder = count % 10
        
        switch remainder {
        case 1 where count % 100 != 11:
            return "блок"
        case 2...4 where count % 100 < 10 || count % 100 >= 20:
            return "блока"
        default:
            return "блоков"
        }
    }
    
    // Пустое состояние списка блоков
    private var emptyBlocksView: some View {
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
    }

    // Редактор блока
    private var blockEditorView: some View {
        VStack {
            if let selectedId = selectedBlockId,
               let selectedBlockIndex = viewModel.blocks.firstIndex(where: { $0.id == selectedId }) {
                BlockEditor(
                    block: Binding(
                        get: { viewModel.blocks[selectedBlockIndex] },
                        set: {
                            viewModel.blocks[selectedBlockIndex] = $0
                            viewModel.markAsModified()
                        }
                    )
                )
                .padding()
            } else {
                emptyEditorView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }

    // Пустое состояние редактора
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

// MARK: - BlockRowView как отдельная структура

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
