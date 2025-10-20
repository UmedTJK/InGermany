import SwiftUI
import ArticleKit
import Combine

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var selectedBlockId: UUID?
    @State private var showPreview = true
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""
    
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
        .navigationTitle(viewModel.document.title) // ✅ ИСПОЛЬЗУЕМ viewModel.document
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
        .background(
            Button("", action: handleKeyboardShortcuts)
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .keyboardShortcut("s", modifiers: .command)
                .keyboardShortcut(.return, modifiers: [.command])
                .keyboardShortcut(.delete, modifiers: .command)
                .keyboardShortcut("d", modifiers: .command)
                .keyboardShortcut("e", modifiers: .command)
                .keyboardShortcut("i", modifiers: .command)
                .opacity(0)
        )
    }
    
    // ✅ НОВЫЙ КОМПОНЕНТ: Заголовок с редактированием
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
                    Text(viewModel.document.title.isEmpty ? "Без названия" : viewModel.document.title) // ✅ ИСПОЛЬЗУЕМ viewModel.document
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
    
    // ✅ МЕТОДЫ ДЛЯ РЕДАКТИРОВАНИЯ ЗАГОЛОВКА
    private func startTitleEditing() {
        editedTitle = viewModel.document.title // ✅ ИСПОЛЬЗУЕМ viewModel.document
        isEditingTitle = true
    }
    
    private func saveTitle() {
        guard !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Обновляем документ с новым названием
        let updatedDocument = ArticleDocument(
            title: editedTitle,
            sections: viewModel.document.sections, // ✅ ИСПОЛЬЗУЕМ viewModel.document
            url: viewModel.document.url // ✅ ИСПОЛЬЗУЕМ viewModel.document
        )
        
        // Перезагружаем ViewModel с обновленным документом
        viewModel.updateDocument(updatedDocument) // ✅ ИСПОЛЬЗУЕМ НОВЫЙ МЕТОД
        
        // Сохраняем изменения
        viewModel.saveDocument()
        
        isEditingTitle = false
    }
    
    private func cancelTitleEditing() {
        editedTitle = viewModel.document.title // ✅ ИСПОЛЬЗУЕМ viewModel.document
        isEditingTitle = false
    }
    
    // ✅ ОБРАБОТЧИК ВСЕХ ГОРЯЧИХ КЛАВИШ
    private func handleKeyboardShortcuts() {
        // Этот метод будет вызываться для любой горячей клавиши
        // Реальная обработка происходит через .keyboardShortcut модификаторы выше
    }
    
    // MARK: - Обработчики горячих клавиш
    
    // ✅ ОБРАБОТЧИК: ⌘⇧N - Показать BlockPicker
    private func showBlockPicker() {
        viewModel.showBlockPicker = true
    }
    
    // ✅ ОБРАБОТЧИК: ⌘S - Сохранить документ
    private func saveDocument() {
        viewModel.saveDocument()
    }
    
    // ✅ ОБРАБОТЧИК: ⌘D - Дублировать выбранный блок
    private func duplicateSelectedBlock() {
        guard let selectedId = selectedBlockId,
              let selectedBlock = viewModel.blocks.first(where: { $0.id == selectedId }) else {
            return
        }
        viewModel.duplicateBlock(selectedBlock)
    }
    
    // ✅ ОБРАБОТЧИК: ⌘⌫ - Удалить выбранный блок
    private func deleteSelectedBlock() {
        guard let selectedId = selectedBlockId,
              let selectedBlock = viewModel.blocks.first(where: { $0.id == selectedId }) else {
            return
        }
        viewModel.removeBlock(selectedBlock)
        // Сбрасываем выбор после удаления
        selectedBlockId = nil
    }
    
    // ✅ ОБРАБОТЧИК: ⌘E - Экспорт документа
    private func exportDocument() {
        viewModel.exportDocument()
    }
    
    // ✅ ОБРАБОТЧИК: ⌘I - Импорт документа
    private func importDocument() {
        viewModel.importDocument()  // ← ПРАВИЛЬНО!
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
                Text(viewModel.document.title) // ✅ ИСПОЛЬЗУЕМ viewModel.document
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
            // Левая часть - управление блоками
            HStack {
                Button(action: {
                    viewModel.showBlockPicker = true
                }) {
                    Label("Добавить блок", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .help("Добавить новый блок (⌘⇧N)")
                
                // Кнопка переключения превью
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
                .keyboardShortcut(.return, modifiers: [.command])
                .help("Переключить предпросмотр (⌘⏎)")
            }
            
            Spacer()
            
            // Центральная часть - экспорт/импорт
            HStack {
                Button(action: exportDocument) {
                    Label("Экспорт", systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut("e", modifiers: .command)
                .help("Экспортировать статью в JSON (⌘E)")
                
                Button(action: importDocument) {
                    Label("Импорт", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut("i", modifiers: .command)
                .help("Импортировать статью из JSON (⌘I)")
            }
            
            Spacer()
            
            // Правая часть - действия
            HStack {
                statusIndicator
                
                Button("Сохранить") {
                    viewModel.saveDocument()
                }
                .disabled(!viewModel.hasUnsavedChanges)
                .keyboardShortcut("s", modifiers: .command)
                .help("Сохранить документ (⌘S)")
                
                // ✅ ДОБАВЛЯЕМ КНОПКИ ДЛЯ УПРАВЛЕНИЯ БЛОКАМИ
                if selectedBlockId != nil {
                    Button(action: duplicateSelectedBlock) {
                        Label("Дублировать", systemImage: "doc.on.doc")
                    }
                    .keyboardShortcut("d", modifiers: .command)
                    .help("Дублировать блок (⌘D)")
                    
                    Button(action: deleteSelectedBlock) {
                        Label("Удалить", systemImage: "trash")
                    }
                    .keyboardShortcut(.delete, modifiers: .command)
                    .help("Удалить блок (⌘⌫)")
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
                
                // ✅ ДОБАВЛЯЕМ ПОДСКАЗКУ ПРО ГОРЯЧИЕ КЛАВИШИ
                if viewModel.blocks.count > 0 {
                    Text("⌘⏎ превью • ⌘⇧N новый блок • ⌘S сохранить • ⌘E экспорт • ⌘I импорт")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
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
                        BlockRowView(block: block, isSelected: selectedBlockId == block.id)
                            .tag(block.id)
                            .contextMenu {
                                Button("Дублировать") {
                                    viewModel.duplicateBlock(block)
                                }
                                .keyboardShortcut("d", modifiers: .command)
                                
                                Button("Удалить", role: .destructive) {
                                    viewModel.removeBlock(block)
                                }
                                .keyboardShortcut(.delete, modifiers: .command)
                            }
                    }
                    .onMove(perform: viewModel.moveBlocks)
                    .onDelete(perform: viewModel.deleteBlocks)
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
    var isSelected: Bool = false
    
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
            
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .opacity(0.6)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(4)
        .help("Выберите и используйте ⌘D для дублирования или ⌘⌫ для удаления")
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
