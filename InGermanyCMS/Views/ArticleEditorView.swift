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
    @State private var previewScale: CGFloat = 0.6
    @State private var fitMode: Bool = false
    @State private var previewWidth: CGFloat? = 300
    @State private var selectedDevice: PreviewDevice = .iPhone17ProMax   // ✅ только один девайс
    @State private var isLandscape: Bool = false
    @State private var backgroundStyle: PreviewBackgroundStyle = .auto
    @State private var showMultiPreview = false


    
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
                    editorPanel.frame(minWidth: 500, maxWidth: .infinity)
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

            if showMultiPreview {
                // --- MULTI PREVIEW: сетка устройств ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 32) {
                        ForEach([PreviewDevice.iPhoneSE,
                                 PreviewDevice.iPhone14,
                                 PreviewDevice.iPhone15,
                                 PreviewDevice.iPhone16,
                                 PreviewDevice.iPhone17ProMax,
                                 PreviewDevice.iPadMini], id: \.self) { device in
                            DeviceFrameView(device: device,
                                            scale: $previewScale,
                                            fitMode: fitMode,
                                            isLandscape: isLandscape,
                                            backgroundStyle: backgroundStyle) {
                                previewBody
                            }
                            .frame(
                                idealWidth: device.size.width * previewScale + 80,
                                maxWidth: device.size.width * previewScale + 120
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                }
            } else {
                // --- SINGLE PREVIEW ---
                HStack {
                    Spacer(minLength: 40)

                    DeviceFrameView(device: selectedDevice,
                                    scale: $previewScale,
                                    fitMode: fitMode,
                                    isLandscape: isLandscape,
                                    backgroundStyle: backgroundStyle) {
                        previewBody
                    }
                    .frame(
                        idealWidth: selectedDevice.size.width * previewScale + 80,
                        maxWidth: selectedDevice.size.width * previewScale + 120
                    )

                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }




    private var previewBody: some View {
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




    
    // MARK: - Preview Header
    private var previewHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Предпросмотр")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // --- Устройство + Масштаб---
            HStack(spacing: 8) {
                // --- Устройство
                Picker("Device", selection: $selectedDevice) {
                    // --- iPhone SE
                    Group {
                        Text("iPhone SE (2/3 gen)").tag(PreviewDevice.iPhoneSE)
                    }
                    
                    // --- iPhone 14 Series
                    Group {
                        Text("iPhone 14").tag(PreviewDevice.iPhone14)
                        Text("iPhone 14 Pro Max").tag(PreviewDevice.iPhone14ProMax)
                    }
                    
                    // --- iPhone 15 Series
                    Group {
                        Text("iPhone 15").tag(PreviewDevice.iPhone15)
                        Text("iPhone 15 Pro").tag(PreviewDevice.iPhone15Pro)
                    }
                    
                    // --- iPhone 16 Series
                    Group {
                        Text("iPhone 16").tag(PreviewDevice.iPhone16)
                        Text("iPhone 16 Pro").tag(PreviewDevice.iPhone16Pro)
                        Text("iPhone 16 Pro Max").tag(PreviewDevice.iPhone16ProMax)
                    }
                    
                    // --- iPhone 17 Series
                    Group {
                        Text("iPhone 17").tag(PreviewDevice.iPhone17)
                        Text("iPhone 17 Pro").tag(PreviewDevice.iPhone17Pro)
                        Text("iPhone 17 Pro Max").tag(PreviewDevice.iPhone17ProMax)
                    }
                    
                    // --- iPad
                    Group {
                        Text("iPad Mini (6 gen)").tag(PreviewDevice.iPadMini)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)

                
                // --- Масштаб ---
                HStack(spacing: 4) {
                    ForEach([0.5, 0.6, 0.75, 1.0], id: \.self) { value in
                        Button("\(Int(value * 100))%") {
                            fitMode = false
                            previewScale = value
                        }
                        .buttonStyle(.borderless)
                        .font(.caption)
                        .padding(4)
                        .background(!fitMode && previewScale == value ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(4)
                    }
                    
                    Button(action: { fitMode = true }) {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                    .buttonStyle(.borderless)
                    .help("Fit to Window")
                }
                
            }
            
            // --- Тема + Доп. кнопки  ---
            HStack(spacing: 8) {
                Text("Theme")
                Button("Light") { backgroundStyle = .light }
                    .buttonStyle(.bordered)
                    .tint(backgroundStyle == .light ? .accentColor : .gray.opacity(0.2))
                Button("Dark") { backgroundStyle = .dark }
                    .buttonStyle(.bordered)
                    .tint(backgroundStyle == .dark ? .accentColor : .gray.opacity(0.2))
                Button("Auto") { backgroundStyle = .auto }
                    .buttonStyle(.bordered)
                    .tint(backgroundStyle == .auto ? .accentColor : .gray.opacity(0.2))
                
                // --- Доп. кнопки ---
                HStack(spacing: 12) {
                    Toggle(isOn: $showMultiPreview) {
                        Image(systemName: "square.split.2x1")
                    }
                    .toggleStyle(.button)
                    .help("Показать несколько устройств")
                    
                    Button {
                        // TODO: сделать скриншот
                    } label: {
                        Image(systemName: "camera")
                    }
                    .buttonStyle(.plain)
                    .help("Сохранить скриншот")
                    
                    Button(action: { viewModel.objectWillChange.send() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .help("Обновить")
                }
            }
            

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
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
