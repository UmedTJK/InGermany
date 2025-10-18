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
    private var autosaveTimer: Timer? // ✅ Добавляем таймер автосохранения
    
    public init(document: ArticleDocument) {
        self.document = document
        loadDocument(document)
        setupChangeTracking()
        setupAutosave() // ✅ Запускаем автосохранение
    }
    
    deinit {
        autosaveTimer?.invalidate() // ✅ Очищаем таймер при деините
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
    
    public func updateBlock(_ updatedBlock: ArticleBlock) {
        if let index = blocks.firstIndex(where: { $0.id == updatedBlock.id }) {
            blocks[index] = updatedBlock
            markAsModified()
        }
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        markAsModified()
    }
    
    public func togglePreview() {
        showPreview.toggle()
    }
    
    public func markAsModified() {
        if !hasUnsavedChanges {
            hasUnsavedChanges = true
        }
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
