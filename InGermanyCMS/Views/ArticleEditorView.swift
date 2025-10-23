import SwiftUI
import ArticleKit
import Combine   // нужно для objectWillChange

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var selectedBlockId: UUID?
    @State private var showPreview = true
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""
    @State private var hostingWindow: NSWindow?
    
    init(document: ArticleDocument) {
        _viewModel = StateObject(wrappedValue: ArticleEditorViewModel(document: document))
        _editedTitle = State(initialValue: document.title)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleHeader
            editorToolbar
            mainContentView
        }
        .getHostingWindow { window in
            self.hostingWindow = window
        }
        .navigationTitle(viewModel.document.title)
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

    // MARK: - Заголовок
    private var titleHeader: some View {
        HStack {
            if isEditingTitle {
                HStack {
                    TextField("Название статьи", text: $editedTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .onSubmit {
                            saveTitle()
                        }
                    
                    Button("Сохранить") {
                        saveTitle()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    
                    Button("Отмена") {
                        cancelTitleEditing()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                HStack {
                    Text(viewModel.document.title.isEmpty ? "Без названия" : viewModel.document.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Button(action: {
                        startTitleEditing()
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Редактировать название")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    // MARK: - Методы редактирования заголовка
    private func startTitleEditing() {
        editedTitle = viewModel.document.title
        isEditingTitle = true
    }
    
    private func saveTitle() {
        guard !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let updatedDocument = ArticleDocument(
            title: editedTitle,
            sections: viewModel.document.sections,
            url: viewModel.document.url
        )
        viewModel.updateDocument(updatedDocument)
        viewModel.saveDocument()
        isEditingTitle = false
    }
    
    private func cancelTitleEditing() {
        editedTitle = viewModel.document.title
        isEditingTitle = false
    }
    
    // MARK: - Горячие клавиши
    private func handleKeyboardShortcuts() {
        // Обработка горячих клавиш будет здесь
    }
    
    private func showBlockPicker() {
        viewModel.showBlockPicker = true
    }
    
    private func saveDocument() {
        viewModel.saveDocument()
    }
    
    private func duplicateSelectedBlock() {
        guard let selectedId = selectedBlockId,
              let selectedBlock = viewModel.blocks.first(where: { $0.id == selectedId }) else { return }
        viewModel.duplicateBlock(selectedBlock)
    }
    
    private func deleteSelectedBlock() {
        guard let selectedId = selectedBlockId,
              let selectedBlock = viewModel.blocks.first(where: { $0.id == selectedId }) else { return }
        viewModel.removeBlock(selectedBlock)
        selectedBlockId = nil
    }
    
    private func exportDocument() {
        print("🟡 [UI] Export button tapped")
        print("🟡 [UI] Hosting window: \(String(describing: hostingWindow))")
        viewModel.exportDocument(using: hostingWindow)
    }
    
    private func importDocument() {
        viewModel.importDocument(using: hostingWindow)
    }
    
    // MARK: - Основной контент
    private var mainContentView: some View {
        Group {
            if showPreview {
                HSplitView {
                    editorPanel.frame(minWidth: 300, maxWidth: .infinity)
                    previewPanel.frame(minWidth: 300, maxWidth: .infinity)
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
            blocksListView.frame(width: 280)
            Divider()
            blockEditorView.frame(maxWidth: .infinity)
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
            Button(action: { viewModel.objectWillChange.send() }) {
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
        DeviceFrameView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.document.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ArticleRenderer(sections: viewModel.blocks.map { $0.toSectionDTO() })
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    
    // MARK: - Toolbar
    private var editorToolbar: some View {
        HStack {
            HStack {
                Button(action: { viewModel.showBlockPicker = true }) {
                    Label("Добавить блок", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .help("Добавить новый блок (⌘⇧N)")
                
                Button(action: { withAnimation { showPreview.toggle() } }) {
                    Label(showPreview ? "Скрыть превью" : "Показать превью",
                          systemImage: showPreview ? "eye.slash" : "eye")
                }
                .keyboardShortcut(.return, modifiers: .command)
            }
            
            Spacer()
            
            HStack {
                Button(action: exportDocument) {
                    Label("Экспорт", systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button(action: importDocument) {
                    Label("Импорт", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut("i", modifiers: .command)
            }
            
            Spacer()
            
            HStack {
                statusIndicator
                Button("Сохранить") {
                    viewModel.saveDocument()
                }
                .disabled(!viewModel.hasUnsavedChanges)
                .keyboardShortcut("s", modifiers: .command)
                
                if selectedBlockId != nil {
                    Button(action: duplicateSelectedBlock) {
                        Label("Дублировать", systemImage: "doc.on.doc")
                    }
                    .keyboardShortcut("d", modifiers: .command)
                    
                    Button(action: deleteSelectedBlock) {
                        Label("Удалить", systemImage: "trash")
                    }
                    .keyboardShortcut(.delete, modifiers: .command)
                }
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
    
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            if viewModel.isSaving {
                ProgressView().scaleEffect(0.8)
                Text("Сохранение...").font(.caption).foregroundColor(.blue)
            } else if viewModel.hasUnsavedChanges {
                Image(systemName: "circle.fill").font(.system(size: 8)).foregroundColor(.orange)
                Text("Не сохранено").font(.caption).foregroundColor(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("Сохранено").font(.caption).foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Список блоков
    private var blocksListView: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Блоки статьи").font(.headline)
                Text("\(viewModel.blocks.count) \(blockCountText)")
                    .font(.caption).foregroundColor(.secondary)
                if viewModel.blocks.count > 0 {
                    Text("⌘⏎ превью • ⌘⇧N новый блок • ⌘S сохранить • ⌘E экспорт • ⌘I импорт")
                        .font(.caption2).foregroundColor(.secondary).opacity(0.7)
                }
            }
            .padding(.horizontal).padding(.top, 16).padding(.bottom, 8)
            
            if viewModel.blocks.isEmpty {
                emptyBlocksView
            } else {
                List(selection: $selectedBlockId) {
                    ForEach(viewModel.blocks) { block in
                        BlockRowView(block: block, isSelected: selectedBlockId == block.id)
                            .tag(block.id)
                            .contextMenu {
                                Button("Дублировать") { viewModel.duplicateBlock(block) }
                                Button("Удалить", role: .destructive) { viewModel.removeBlock(block) }
                            }
                    }
                    .onMove(perform: viewModel.moveBlocks)
                    .onDelete(perform: viewModel.deleteBlocks)
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var blockCountText: String {
        let count = viewModel.blocks.count
        let remainder = count % 10
        switch remainder {
        case 1 where count % 100 != 11: return "блок"
        case 2...4 where count % 100 < 10 || count % 100 >= 20: return "блока"
        default: return "блоков"
        }
    }
    
    private var emptyBlocksView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text").font(.system(size: 40)).foregroundColor(.secondary)
            Text("Нет блоков").font(.headline).foregroundColor(.secondary)
            Text("Добавьте первый блок чтобы начать").font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
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
    
    private var emptyEditorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cursorarrow.rays").font(.system(size: 50)).foregroundColor(.secondary)
            Text("Выберите блок для редактирования").font(.title2).foregroundColor(.secondary)
            Text("Выберите блок из списка слева чтобы начать редактирование")
                .font(.body).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - BlockRowView
struct BlockRowView: View {
    let block: ArticleBlock
    var isSelected: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: blockTypeIcon)
                .foregroundColor(blockTypeColor)
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(block.type.rawValue.capitalized).font(.headline)
                if !block.content.isEmpty {
                    Text(block.content.prefix(30) + (block.content.count > 30 ? "..." : ""))
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12)).foregroundColor(.secondary).opacity(0.6)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
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
