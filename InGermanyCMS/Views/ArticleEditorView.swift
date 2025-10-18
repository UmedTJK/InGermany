import SwiftUI
import ArticleKit
import Combine  // ✅ Добавляем импорт Combine

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var selectedBlockId: UUID?
    @State private var showPreview = true // По умолчанию показываем превью
    
    let document: ArticleDocument
    
    init(document: ArticleDocument) {
        self.document = document
        _viewModel = StateObject(wrappedValue: ArticleEditorViewModel(document: document))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель инструментов
            editorToolbar
            
            // Основной контент - Split View
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
                // Split View с редактором и превью
                HSplitView {
                    // Левая панель - редактор
                    editorPanel
                        .frame(minWidth: 300, maxWidth: .infinity)
                    
                    // Правая панель - превью
                    previewPanel
                        .frame(minWidth: 300, maxWidth: .infinity)
                }
            } else {
                // Полноэкранный редактор
                editorPanel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Панель редактора
    
    private var editorPanel: some View {
        HStack(spacing: 0) {
            // Список блоков
            blocksListView
                .frame(width: 280)
            
            Divider()
            
            // Редактор выбранного блока
            blockEditorView
                .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Панель превью
    
    private var previewPanel: some View {
        VStack(spacing: 0) {
            // Заголовок превью
            previewHeader
            
            // Контент превью
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
            
            // Кнопка обновления превью
            Button(action: {
                // Принудительное обновление превью
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
                // Заголовок статьи
                Text(document.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Рендерер статьи
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
            }
            
            Spacer()
            
            // Правая часть - действия
            HStack {
                // Индикатор состояния
                if viewModel.isSaving {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Сохранение...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .opacity(viewModel.hasUnsavedChanges ? 0.3 : 1.0)
                    Text("Сохранено")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(viewModel.hasUnsavedChanges ? 0.3 : 1.0)
                }
                
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
    
    private var blocksListView: some View {
        VStack {
            Text("Блоки статьи")
                .font(.headline)
                .padding()
            
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

// MARK: - Восстанавливаем BlockRowView

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
