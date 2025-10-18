import SwiftUI
import Combine

public class ArticleEditorViewModel: ObservableObject {
    @Published public var blocks: [ArticleBlock] = []
    @Published public var showBlockPicker = false
    @Published public var showPreview = false
    @Published public var isSaving = false
    @Published public var hasUnsavedChanges = false
    
    private var document: ArticleDocument
    private var originalBlocks: [ArticleBlock] = []
    private var cancellables = Set<AnyCancellable>()
    private var autosaveTimer: Timer?
    
    public init(document: ArticleDocument) {
        self.document = document
        loadDocument(document)
        setupChangeTracking()
        setupAutosave()
    }
    
    deinit {
        autosaveTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    public func loadDocument(_ document: ArticleDocument) {
        self.document = document
        self.blocks = document.sections.map { ArticleBlock.fromSection($0) }
        self.originalBlocks = blocks
        self.hasUnsavedChanges = false
    }
    
    public func saveDocument() {
        guard hasUnsavedChanges else { return }
        
        isSaving = true
        
        // Имитация процесса сохранения
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let updatedSections = self.blocks.map { $0.toSectionDTO() }
            let updatedDocument = ArticleDocument(
                title: self.document.title,
                sections: updatedSections,
                url: self.document.url
            )
            
            self.saveToFileSystem(updatedDocument)
            
            self.originalBlocks = self.blocks
            self.hasUnsavedChanges = false
            self.isSaving = false
            
            print("💾 Документ сохранен: \(updatedDocument.title)")
        }
    }
    
    public func addBlock(_ type: BlockType) {
        let newBlock = ArticleBlock(type: type)
        blocks.append(newBlock)
        markAsModified()
    }
    
    public func removeBlock(_ block: ArticleBlock) {
        blocks.removeAll { $0.id == block.id }
        markAsModified()
    }
    
    public func deleteBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
        markAsModified()
    }
    
    public func duplicateBlock(_ block: ArticleBlock) {
        let duplicatedBlock = ArticleBlock(
            type: block.type,
            content: block.content,
            items: block.items.map { ArticleItemDTO(text: $0.text, isCompleted: $0.isCompleted) }
        )
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks.insert(duplicatedBlock, at: index + 1)
            markAsModified()
        }
    }
    
    public func updateBlock(_ updatedBlock: ArticleBlock) {
        if let index = blocks.firstIndex(where: { $0.id == updatedBlock.id }) {
            blocks[index] = updatedBlock
            markAsModified()
        }
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        markAsModified()
        print("🔀 Блоки перемещены: с \(source) на позицию \(destination)")
    }
    
    public func togglePreview() {
        showPreview.toggle()
    }
    
    public func markAsModified() {
        if !hasUnsavedChanges {
            hasUnsavedChanges = true
        }
    }
    
    // ✅ ДОБАВЛЯЕМ МЕТОД ДЛЯ ОБНОВЛЕНИЯ ДОКУМЕНТА
    public func updateDocument(_ newDocument: ArticleDocument) {
        self.document = newDocument
        self.blocks = newDocument.sections.map { ArticleBlock.fromSection($0) }
        self.originalBlocks = blocks
        self.hasUnsavedChanges = true
    }
    
    // MARK: - Экспорт/Импорт
    
    public func exportDocument() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "\(document.title).json"
        savePanel.title = "Экспорт статьи"
        savePanel.message = "Выберите место для сохранения статьи в формате JSON"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                let data = try encoder.encode(document)
                try data.write(to: url)
                
                print("✅ Статья экспортирована: \(url.path)")
                showExportSuccessAlert()
            } catch {
                print("❌ Ошибка экспорта: \(error)")
                showExportErrorAlert(error)
            }
        }
    }
    
    public func importDocument() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Импорт статьи"
        openPanel.message = "Выберите JSON файл статьи для импорта"
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                let data = try Data(contentsOf: url)
                let importedDocument = try JSONDecoder().decode(ArticleDocument.self, from: data)
                
                // Загружаем импортированный документ
                self.document = importedDocument
                self.blocks = importedDocument.sections.map { ArticleBlock.fromSection($0) }
                self.originalBlocks = blocks
                self.hasUnsavedChanges = false
                
                print("✅ Статья импортирована: \(importedDocument.title)")
                showImportSuccessAlert(importedDocument.title)
            } catch {
                print("❌ Ошибка импорта: \(error)")
                showImportErrorAlert(error)
            }
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func showExportSuccessAlert() {
        let alert = NSAlert()
        alert.messageText = "Статья успешно экспортирована"
        alert.informativeText = "Файл сохранен в выбранной директории"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showExportErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Ошибка экспорта"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showImportSuccessAlert(_ title: String) {
        let alert = NSAlert()
        alert.messageText = "Статья успешно импортирована"
        alert.informativeText = "\"\(title)\" загружена в редактор"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showImportErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Ошибка импорта"
        alert.informativeText = "Не удалось загрузить статью: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // MARK: - Автосохранение
    
    private func setupAutosave() {
        // Таймер с интервалом 3 секунды
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Сохраняем только если есть несохраненные изменения
            if self.hasUnsavedChanges && !self.isSaving {
                print("🔄 Автосохранение...")
                self.saveDocument()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupChangeTracking() {
        // Отслеживаем изменения в блоках
        $blocks
            .dropFirst() // Пропускаем начальное значение
            .sink { [weak self] newBlocks in
                guard let self = self else { return }
                
                // Сравниваем с оригинальными блоками
                let hasChanges = newBlocks != self.originalBlocks
                if self.hasUnsavedChanges != hasChanges {
                    self.hasUnsavedChanges = hasChanges
                }
            }
            .store(in: &cancellables)
    }
    
    private func saveToFileSystem(_ document: ArticleDocument) {
        guard let url = document.url else {
            print("⚠️ Не удалось сохранить: URL документа не указан")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(document)
            try data.write(to: url)
            print("✅ Документ сохранен по пути: \(url.path)")
        } catch {
            print("❌ Ошибка сохранения: \(error)")
        }
    }
}
