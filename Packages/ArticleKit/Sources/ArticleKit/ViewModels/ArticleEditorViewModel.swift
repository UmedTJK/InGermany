import Foundation
import SwiftUI
import ArticleKit
import Combine

#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

@MainActor
final class ArticleEditorViewModel: ObservableObject, Identifiable {
    nonisolated let id = UUID()
    
    @Published public var document: ArticleDocument
    @Published public var blocks: [ArticleBlock]
    @Published public var showBlockPicker = false
    @Published public var showPreview = true
    @Published public var isSaving = false
    @Published public var hasUnsavedChanges = false
    @Published public var lastError: String? = nil
    
    // MARK: - Initialization
    public init(document: ArticleDocument) {
        self.document = document
        self.blocks = document.sections.map { ArticleBlock.fromSection($0) }
    }
    
    public init(title: String = "", blocks: [ArticleBlock] = []) {
        self.document = ArticleDocument(title: title, sections: [])
        self.blocks = blocks
    }
    
    // MARK: - Document Management
    public func updateDocument(_ newDocument: ArticleDocument) {
        self.document = newDocument
        self.blocks = newDocument.sections.map { ArticleBlock.fromSection($0) }
        self.hasUnsavedChanges = true
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
    }

    
    public func duplicateBlock(_ block: ArticleBlock) {
        let newBlock = ArticleBlock(type: block.type, content: block.content)
        blocks.append(newBlock)
        markAsModified()
    }
    
    public func removeBlock(_ block: ArticleBlock) {
        blocks.removeAll { $0.id == block.id }
        markAsModified()
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        markAsModified()
    }
    
    public func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
        markAsModified()
    }
    
    public func markAsModified() {
        hasUnsavedChanges = true
    }
    
    // MARK: - Export/Import (macOS only)
    #if os(macOS)
    public func exportDocument(using window: NSWindow?) {
        print("=== 🔵 [EXPORT DIAGNOSTICS] ===")
        print("🔵 [1/6] Function started")
        print("🔵 [2/6] Thread: \(Thread.current)")
        print("🔵 [3/6] Main thread: \(Thread.isMainThread)")
        print("🔵 [4/6] Window: \(window != nil ? "PRESENT" : "NIL")")
        print("🔵 [5/6] Document: '\(document.title)'")
        print("🔵 [6/6] Blocks: \(blocks.count)")
        
        guard let window = window else {
            print("🔴 [ERROR] No window available")
            self.lastError = "No active window for export"
            return
        }
        
        guard Thread.isMainThread else {
            print("🔴 [ERROR] Not on main thread")
            DispatchQueue.main.async { [weak self] in
                self?.exportDocument(using: window)
            }
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
            print("✅ Serialization successful: \(testData.count) bytes")
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.json]
            savePanel.nameFieldStringValue = sanitizedSuggestedFilename()
            savePanel.title = "Экспорт статьи"
            savePanel.message = "Выберите место для сохранения статьи"
            
            let response = savePanel.runModal()
            if response == .OK, let url = savePanel.url {
                try testData.write(to: url, options: .atomic)
                print("✅ File saved successfully!")
                showExportSuccessAlert(window: window)
            } else {
                print("🔵 Export cancelled")
            }
            
        } catch {
            print("🔴 Export error: \(error)")
            showExportErrorAlert(error, window: window)
        }
        
        print("=== 🟢 [EXPORT COMPLETE] ===")
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
                print("✅ Документ импортирован: \(imported.title)")
            } catch {
                print("❌ Ошибка импорта: \(error)")
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
    nonisolated static func == (lhs: ArticleEditorViewModel, rhs: ArticleEditorViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
