import SwiftUI
import ArticleKit
import Combine

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    
    @State private var selectedBlockId: UUID?
    @State private var showPreview = true
    @State private var isEditingTitle = false
    @State private var editedTitle: String = ""
    @State private var hostingWindow: NSWindow?
    @State private var previewScale: CGFloat = 0.6
    @State private var fitMode: Bool = false
    @State private var showMultiPreview = false
    @State private var selectedDevice: PreviewDevice = .iPhone17ProMax
    @State private var isLandscape: Bool = false
    
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
                        Button("Отмена") { viewModel.showBlockPicker = false }
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
                TextField("Название статьи", text: $editedTitle)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.title2.weight(.semibold))
                    .onSubmit { saveTitle() }
                
                Button("Сохранить") { saveTitle() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                
                Button("Отмена") { cancelTitleEditing() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else {
                Text(viewModel.document.title.isEmpty ? "Без названия" : viewModel.document.title)
                    .font(.title2.weight(.semibold))
                    .lineLimit(1)
                
                Button(action: { startTitleEditing() }) {
                    Image(systemName: "pencil").font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Редактировать название")
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color.secondary.opacity(0.05))
    }
    
    // MARK: - Основной контент
    private var mainContentView: some View {
        Group {
            if showPreview {
                HSplitView {
                    editorPanel.frame(minWidth: 500, maxWidth: .infinity)
                    previewPanel.frame(minWidth: 300, maxWidth: .infinity)
                }
            } else {
                editorPanel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var editorPanel: some View {
        HStack(spacing: 0) {
            blocksListView.frame(width: 280)
            Divider()
            blockEditorView.frame(maxWidth: .infinity)
        }
    }
    
    private var previewPanel: some View {
        VStack(spacing: 0) {
            previewHeader
            if showMultiPreview {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 32) {
                        ForEach(PreviewDevice.allCases, id: \.self) { device in
                            DeviceFrameView(device: device,
                                            scale: $previewScale,
                                            fitMode: fitMode,
                                            isLandscape: isLandscape) {
                                previewBody
                            }
                        }
                    }
                    .padding(.horizontal, 40).padding(.vertical, 16)
                }
            } else {
                HStack {
                    Spacer(minLength: 40)
                    DeviceFrameView(device: selectedDevice,
                                    scale: $previewScale,
                                    fitMode: fitMode,
                                    isLandscape: isLandscape) {
                        previewBody
                    }
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color.secondary.opacity(0.05))
    }

    private var previewBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.document.title)
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)
                ArticleRenderer(sections: viewModel.blocks.map { $0.toSectionDTO() })
            }
            .padding()
        }
    }
    
    // MARK: - Preview Header
    private var previewHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Предпросмотр").font(.headline)
            
            // --- выбор устройства и масштаба ---
            HStack(spacing: 8) {
                Picker("Device", selection: $selectedDevice) {
                    ForEach(PreviewDevice.allCases) { device in
                        Label(device.rawValue, systemImage: device.icon).tag(device)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 220)
                
                HStack(spacing: 4) {
                    ForEach([0.5, 0.6, 0.75, 1.0], id: \.self) { value in
                        Button("\(Int(value * 100))%") {
                            fitMode = false
                            previewScale = value
                        }
                        .buttonStyle(.borderless).font(.caption)
                    }
                    Button(action: { fitMode = true }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            // --- УДАЛЕН переключатель темы предпросмотра ---
            HStack(spacing: 8) {
                Spacer()
                Toggle(isOn: $showMultiPreview) {
                    Image(systemName: "square.split.2x1")
                }
                .toggleStyle(.button)
                .help("Показать несколько устройств")
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
    }
    
    // MARK: - Toolbar (глобальный)
    private var editorToolbar: some View {
        HStack {
            Button(action: { viewModel.showBlockPicker = true }) {
                Label("Добавить блок", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            
            Button(action: { withAnimation { showPreview.toggle() } }) {
                Label(showPreview ? "Скрыть превью" : "Показать превью",
                      systemImage: showPreview ? "eye.slash" : "eye")
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Spacer()
            
            Button(action: exportDocument) {
                Label("Экспорт", systemImage: "square.and.arrow.up")
            }
            .keyboardShortcut("e", modifiers: .command)
            
            Button(action: importDocument) {
                Label("Импорт", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut("i", modifiers: .command)
            
            Spacer()
            
            statusIndicator
            Button("Сохранить") { viewModel.saveDocument() }
                .disabled(!viewModel.hasUnsavedChanges)
                .keyboardShortcut("s", modifiers: .command)
            
            // ТОЛЬКО глобальный тоггл темы приложения
            ThemeToggle(scope: .app)
        }
        .padding()
    }
    
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            if viewModel.isSaving {
                ProgressView().scaleEffect(0.8)
                Text("Сохранение...").font(.caption)
            } else if viewModel.hasUnsavedChanges {
                Image(systemName: "circle.fill").font(.system(size: 8))
                Text("Не сохранено").font(.caption)
            } else {
                Image(systemName: "checkmark.circle.fill")
                Text("Сохранено").font(.caption)
            }
        }
    }
    
    // MARK: - Blocks list
    private var blocksListView: some View {
        VStack {
            Text("Блоки статьи").font(.headline)
            if viewModel.blocks.isEmpty {
                Text("Нет блоков")
            } else {
                List(selection: $selectedBlockId) {
                    ForEach(viewModel.blocks) { block in
                        BlockRowView(block: block, isSelected: selectedBlockId == block.id)
                            .tag(block.id)
                    }
                }
            }
        }
    }
    
    private var blockEditorView: some View {
        VStack {
            if let selectedId = selectedBlockId,
               let idx = viewModel.blocks.firstIndex(where: { $0.id == selectedId }) {
                BlockEditor(
                    block: Binding(
                        get: { viewModel.blocks[idx] },
                        set: {
                            viewModel.blocks[idx] = $0
                            viewModel.markAsModified()
                        }
                    )
                )
            } else {
                Text("Выберите блок для редактирования").foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Methods
    private func startTitleEditing() { editedTitle = viewModel.document.title; isEditingTitle = true }
    private func saveTitle() {
        guard !editedTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let updated = ArticleDocument(title: editedTitle,
                                      sections: viewModel.document.sections,
                                      url: viewModel.document.url)
        viewModel.updateDocument(updated)
        viewModel.saveDocument()
        isEditingTitle = false
    }
    private func cancelTitleEditing() { editedTitle = viewModel.document.title; isEditingTitle = false }
    private func exportDocument() { viewModel.exportDocument(using: hostingWindow) }
    private func importDocument() { viewModel.importDocument(using: hostingWindow) }
}

// MARK: - BlockRowView
struct BlockRowView: View {
    let block: ArticleBlock
    var isSelected: Bool = false
    
    var body: some View {
        HStack {
            Text(block.type.rawValue.capitalized)
            if !block.content.isEmpty {
                Text(block.content.prefix(30) + (block.content.count > 30 ? "..." : ""))
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
}
