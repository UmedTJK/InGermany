import Foundation
import SwiftUI
import ArticleKit
import Combine

#if os(macOS)
import AppKit
internal import UniformTypeIdentifiers
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
    
    public func markAsModified() {
        hasUnsavedChanges = true
    }
    
    // MARK: - Block Management
    public func addBlock(_ type: BlockType) {
        let newBlock: ArticleBlock
        switch type {
        case .paragraph, .info, .warning, .tip, .quote:
            newBlock = ArticleBlock(type: type, content: "")
        case .list:
            let defaultItem = ArticleItemDTO(text: "")
            newBlock = ArticleBlock(type: .list, items: [defaultItem])
        case .checklist:
            let defaultItem = ArticleItemDTO(text: "", isCompleted: false)
            newBlock = ArticleBlock(type: .checklist, items: [defaultItem])
        case .faq:
            let answerItem = ArticleItemDTO(text: "Ответ")
            newBlock = ArticleBlock(type: .faq, content: "Вопрос", items: [answerItem])
        case .links:
            let linkItem = ArticleItemDTO(text: "", title: "Новая ссылка", articleId: "")
            newBlock = ArticleBlock(type: .links, items: [linkItem])
        case .image:
            newBlock = ArticleBlock(type: .image, imageData: ImageData())
        }
        blocks.append(newBlock)
        hasUnsavedChanges = true
    }
    
    public func removeBlock(_ block: ArticleBlock) {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks.remove(at: index)
            hasUnsavedChanges = true
        }
    }
    
    public func duplicateBlock(_ block: ArticleBlock) {
        let duplicatedBlock = ArticleBlock(
            type: block.type,
            content: block.content,
            items: block.items.map { ArticleItemDTO(
                text: $0.text,
                isCompleted: $0.isCompleted,
                title: $0.title,
                articleId: $0.articleId
            )},
            imageData: block.imageData
        )
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks.insert(duplicatedBlock, at: index + 1)
            hasUnsavedChanges = true
        }
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        hasUnsavedChanges = true
    }
    
    public func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
        hasUnsavedChanges = true
    }
    
    // MARK: - Export/Import
    #if os(macOS)
    public func exportDocument() {
        precondition(Thread.isMainThread, "exportDocument() must run on main thread")
        print("=== DEBUG [export] start ===")
        print("📝 Document title: \(document.title)")
        print("📦 Blocks count: \(blocks.count)")
        
        do {
            let data = try exportToJSON()
            print("✅ JSON encoding successful, data size: \(data.count) bytes")
            
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.canCreateDirectories = true
            panel.isExtensionHidden = false
            panel.title = "Экспорт статьи"
            panel.message = "Выберите место для сохранения статьи"
            panel.nameFieldStringValue = sanitizedSuggestedFilename()
            
            if let window = NSApp.keyWindow ?? NSApp.mainWindow {
                window.beginSheet(panel) { [weak self] response in
                    guard let self else { return }
                    if response == .OK, let url = panel.url {
                        do {
                            try data.write(to: url, options: .atomic)
                            self.hasUnsavedChanges = false
                            print("✅ File saved: \(url.path)")
                            self.showExportSuccessAlert()
                        } catch {
                            self.lastError = error.localizedDescription
                            print("❌ Write error: \(error)")
                            self.showExportErrorAlert(error)
                        }
                    } else {
                        print("⚠️ User cancelled export (sheet)")
                    }
                }
            } else {
                let response = panel.runModal()
                if response == .OK, let url = panel.url {
                    do {
                        try data.write(to: url, options: .atomic)
                        hasUnsavedChanges = false
                        print("✅ File saved: \(url.path)")
                        showExportSuccessAlert()
                    } catch {
                        lastError = error.localizedDescription
                        print("❌ Write error: \(error)")
                        showExportErrorAlert(error)
                    }
                } else {
                    print("⚠️ User cancelled export (modal)")
                }
            }
        } catch {
            lastError = error.localizedDescription
            print("❌ Export error: \(error)")
            showExportErrorAlert(error)
        }
        print("=== DEBUG [export] done ===")
    }
    #endif
    
    // MARK: - JSON Methods
    @discardableResult
    public func exportToJSON() throws -> Data {
        let document = ArticleDocument(
            title: document.title,
            sections: blocks.map { $0.toSectionDTO() },
            url: nil
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        
        let data = try encoder.encode(document)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== Article JSON ===\n\(jsonString)\n=====================")
        }
        return data
    }
    
    public func importFromJSON(_ data: Data) throws {
        let decoder = JSONDecoder()
        let document = try decoder.decode(ArticleDocument.self, from: data)
        self.blocks = document.sections.map { ArticleBlock.fromSection($0) }
        self.document = ArticleDocument(
            title: document.title,
            sections: document.sections,
            url: self.document.url
        )
        self.hasUnsavedChanges = true
    }
    
    #if os(macOS)
    public func importDocument() {
        precondition(Thread.isMainThread, "importDocument() must run on main thread")
        print("=== DEBUG: Starting importDocument() ===")
        
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.title = "Импорт статьи"
        openPanel.message = "Выберите JSON файл статьи"
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            print("✅ User selected URL: \(url.path)")
            do {
                let data = try Data(contentsOf: url)
                try importFromJSON(data)
                
                let importedDocument = ArticleDocument(
                    title: document.title,
                    sections: blocks.map { $0.toSectionDTO() },
                    url: document.url
                )
                updateDocument(importedDocument)
                
                print("✅ Статья импортирована: \(url.path)")
                showImportSuccessAlert()
            } catch {
                lastError = error.localizedDescription
                print("❌ Ошибка импорта: \(error)")
                showImportErrorAlert(error)
            }
        } else {
            print("⚠️ User cancelled import")
        }
    }
    #endif
    
    // MARK: - Alert Methods
    private func showExportSuccessAlert() {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Статья экспортирована"
        alert.informativeText = "Статья \"\(document.title)\" успешно экспортирована в JSON"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
    
    private func showExportErrorAlert(_ error: Error) {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Ошибка экспорта"
        alert.informativeText = "Не удалось экспортировать статью: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
    
    private func showImportSuccessAlert() {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Статья импортирована"
        alert.informativeText = "Статья успешно импортирована из JSON"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
    
    private func showImportErrorAlert(_ error: Error) {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Ошибка импорта"
        alert.informativeText = "Не удалось импортировать статью: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        #endif
    }
}

// MARK: - Filename helper
#if os(macOS)
private extension ArticleEditorViewModel {
    func sanitizedSuggestedFilename() -> String {
        let base = document.title.isEmpty ? "Article" : document.title
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let cleaned = base.components(separatedBy: invalid).joined(separator: "_")
        return cleaned + ".json"
    }
}
#endif

// MARK: - Hashable & Equatable
extension ArticleEditorViewModel: Hashable {
    nonisolated static func == (lhs: ArticleEditorViewModel, rhs: ArticleEditorViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
