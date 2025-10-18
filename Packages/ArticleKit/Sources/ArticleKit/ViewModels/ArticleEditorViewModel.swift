import SwiftUI
import Combine

public class ArticleEditorViewModel: ObservableObject {
    @Published public var blocks: [ArticleBlock] = []
    @Published public var showBlockPicker = false
    @Published public var showPreview = false
    
    private var document: ArticleDocument
    
    public init(document: ArticleDocument) {
        self.document = document
        loadDocument(document)
    }
    
    // MARK: - Public Methods
    
    public func loadDocument(_ document: ArticleDocument) {
        self.document = document
        self.blocks = document.sections.map { ArticleBlock.fromSection($0) }
    }
    
    public func saveDocument() {
        let updatedSections = blocks.map { $0.toSectionDTO() }
        let updatedDocument = ArticleDocument(
            title: document.title,
            sections: updatedSections,
            url: document.url
        )
        
        // Временная реализация - логируем
        print("💾 Сохранение документа: \(updatedDocument.title) с \(updatedSections.count) секциями")
    }
    
    public func addBlock(_ type: BlockType) {
        let newBlock = ArticleBlock(type: type)
        blocks.append(newBlock)
    }
    
    public func removeBlock(_ block: ArticleBlock) {
        blocks.removeAll { $0.id == block.id }
    }
    
    public func updateBlock(_ updatedBlock: ArticleBlock) {
        if let index = blocks.firstIndex(where: { $0.id == updatedBlock.id }) {
            blocks[index] = updatedBlock
        }
    }
    
    public func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
    }
    
    public func togglePreview() {
        showPreview.toggle()
    }
}
