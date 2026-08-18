import Foundation
import SwiftUI
//import ArticleKit
import Combine

#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

// MARK: - UndoRedo Service
@MainActor
public class UndoRedoService<T: Equatable>: ObservableObject {
    @Published public private(set) var canUndo: Bool = false
    @Published public private(set) var canRedo: Bool = false
    
    private var undoStack: [T] = []
    private var redoStack: [T] = []
    private var currentState: T
    private let maxHistorySize: Int
    
    public init(initialState: T, maxHistorySize: Int = 50) {
        self.currentState = initialState
        self.maxHistorySize = maxHistorySize
        self.undoStack.reserveCapacity(maxHistorySize)
    }
    
    public func registerChange(_ newState: T) {
        guard newState != currentState else { return }
        undoStack.append(currentState)
        
        if undoStack.count > maxHistorySize {
            undoStack.removeFirst()
        }
        
        redoStack.removeAll()
        currentState = newState
        updateButtonStates()
    }
    
    public func undo() -> T? {
        guard !undoStack.isEmpty else { return nil }
        redoStack.append(currentState)
        currentState = undoStack.removeLast()
        updateButtonStates()
        return currentState
    }
    
    public func redo() -> T? {
        guard !redoStack.isEmpty else { return nil }
        undoStack.append(currentState)
        currentState = redoStack.removeLast()
        updateButtonStates()
        return currentState
    }
    
    public func clearHistory() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    public func getCurrentState() -> T {
        return currentState
    }
}

// MARK: - ArticleEditorViewModel
@MainActor
public final class ArticleEditorViewModel: ObservableObject, Identifiable {
    public nonisolated let id = UUID()
    
    @Published public var document: ArticleDocument
    @Published public var blocks: [ArticleBlock]
    @Published public var showBlockPicker = false
    @Published public var showPreview = true
    @Published public var isSaving = false
    @Published public var hasUnsavedChanges = false
    @Published public var lastError: String? = nil
    
    // Undo/Redo система
    @Published public private(set) var canUndo: Bool = false
    @Published public private(set) var canRedo: Bool = false
    
    private var undoRedoService: UndoRedoService<[ArticleBlock]>
    private var cancellables: Set<AnyCancellable>
    
    // MARK: - Initialization
    public init(document: ArticleDocument) {
        // создаем initialBlocks локально
        let initialBlocks = document.sections.map { ArticleBlock.fromSection($0) }
        
        self.document = document
        self.blocks = initialBlocks
        self.undoRedoService = UndoRedoService(initialState: initialBlocks)
        self.cancellables = []
        
        self.setupUndoRedoBindings()
    }
    
    public init(title: String = "", blocks: [ArticleBlock] = []) {
        let initialDocument = ArticleDocument(title: title, sections: [])
        
        self.document = initialDocument
        self.blocks = blocks
        self.undoRedoService = UndoRedoService(initialState: blocks)
        self.cancellables = []
        
        self.setupUndoRedoBindings()
    }
    
    private func setupUndoRedoBindings() {
        undoRedoService.$canUndo
            .assign(to: \.canUndo, on: self)
            .store(in: &cancellables)
        
        undoRedoService.$canRedo
            .assign(to: \.canRedo, on: self)
            .store(in: &cancellables)
        
        $blocks
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newBlocks in
                self?.undoRedoService.registerChange(newBlocks)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Undo/Redo Methods
    public func undo() {
        if let previousState = undoRedoService.undo() {
            self.blocks = previousState
            self.hasUnsavedChanges = true
            print("↩️ Undo выполнен, блоков: \(blocks.count)")
        }
    }
    
    public func redo() {
        if let nextState = undoRedoService.redo() {
            self.blocks = nextState
            self.hasUnsavedChanges = true
            print("↪️ Redo выполнен, блоков: \(blocks.count)")
        }
    }
    
    public func clearHistory() {
        undoRedoService.clearHistory()
        print("🧹 История Undo/Redo очищена")
    }
    
    // MARK: - Document Management
    public func updateDocument(_ newDocument: ArticleDocument) {
        let newBlocks = newDocument.sections.map { ArticleBlock.fromSection($0) }
        self.document = newDocument
        self.blocks = newBlocks
        self.hasUnsavedChanges = true
        undoRedoService.registerChange(newBlocks)
    }
    
    public func saveDocument() {
        let updatedDocument = ArticleDocument(
            title: document.title,
            sections: blocks.map { $0.toSectionDTO() },
            url: document.url
        )
        self.document = updatedDocument
        
        if let url = document.url {
            do {
                isSaving = true
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                let data = try encoder.encode(updatedDocument)
                try data.write(to: url)
                hasUnsavedChanges = false
                print("✅ Документ сохранен: \(url.path)")
            } catch {
                lastError = error.localizedDescription
                print("❌ Ошибка сохранения: \(error)")
            }
            isSaving = false
        }
    }
    
    // MARK: - Block Management
    public func addBlock(_ type: BlockType) {
        let newBlock = ArticleBlock(type: type)
        blocks.append(newBlock)
        hasUnsavedChanges = true
        print("➕ Добавлен блок типа: \(type.rawValue)")
    }
    
    public func duplicateBlock(_ block: ArticleBlock) {
        let newBlock = ArticleBlock(type: block.type, content: block.content)
        blocks.append(newBlock)
        markAsModified()
        print("📋 Дублирован блок типа: \(block.type.rawValue)")
    }
    
    public func removeBlock(_ block: ArticleBlock) {
        blocks.removeAll { $0.id == block.id }
        markAsModified()
        print("🗑️ Удален блок типа: \(block.type.rawValue)")
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        markAsModified()
        print("↕️ Перемещены блоки: \(source.count) → позиция \(destination)")
    }
    
    public func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
        markAsModified()
        print("🗑️ Удалены блоки по индексам: \(offsets)")
    }
    
    public func markAsModified() {
        hasUnsavedChanges = true
    }
    
    // MARK: - Export/Import (macOS only)
    #if os(macOS)
    public func exportDocument(using window: NSWindow?) {
        guard let window = window else {
            self.lastError = "No active window for export"
            return
        }
        
        do {
            let testDocument = ArticleDocument(
                title: document.title,
                sections: blocks.map { $0.toSectionDTO() },
                url: nil
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let testData = try encoder.encode(testDocument)
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.json]
            savePanel.nameFieldStringValue = sanitizedSuggestedFilename()
            savePanel.title = "Экспорт статьи"
            savePanel.message = "Выберите место для сохранения статьи"
            
            let response = savePanel.runModal()
            if response == .OK, let url = savePanel.url {
                try testData.write(to: url, options: .atomic)
                showExportSuccessAlert(window: window)
            }
            
        } catch {
            showExportErrorAlert(error, window: window)
        }
    }
    
    public func importDocument(using window: NSWindow?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.title = "Импорт статьи"
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                let data = try Data(contentsOf: url)
                let imported = try JSONDecoder().decode(ArticleDocument.self, from: data)
                self.document = imported
                self.blocks = imported.sections.map { ArticleBlock.fromSection($0) }
                self.hasUnsavedChanges = true
                undoRedoService.registerChange(blocks)
            } catch {
                self.lastError = error.localizedDescription
            }
        }
    }
    
    private func sanitizedSuggestedFilename() -> String {
        let base = document.title.isEmpty ? "Article" : document.title
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleaned = base.components(separatedBy: invalid).joined(separator: "_")
        return cleaned + ".json"
    }
    
    private func showExportSuccessAlert(window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = "Статья экспортирована"
        alert.informativeText = "Статья успешно экспортирована в JSON"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    private func showExportErrorAlert(_ error: Error, window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = "Ошибка экспорта"
        alert.informativeText = "Не удалось экспортировать статью: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    #endif
}

extension ArticleEditorViewModel: Hashable {
    nonisolated public static func == (lhs: ArticleEditorViewModel, rhs: ArticleEditorViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
