import SwiftUI
import Foundation

#if canImport(AppKit)
import AppKit
#endif

public class ArticleLibraryViewModel: ObservableObject {
    @Published public var articles: [ArticleMetadata] = []
    
    private let fileManager = FileManager.default
    private let libraryDirectory: URL
    
    public struct ArticleMetadata: Identifiable {
        public let id = UUID()
        public let title: String
        public let url: URL
        public let modified: Date
        
        public init(title: String, url: URL, modified: Date) {
            self.title = title
            self.url = url
            self.modified = modified
        }
    }
    
    public init() {
        // Определяем директорию для библиотеки статей
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        libraryDirectory = documentsURL.appendingPathComponent("ArticleLibrary")
        
        // Создаем директорию если она не существует
        try? fileManager.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
        
        // Загружаем статьи при инициализации
        refreshLibrary()
    }
    
    // MARK: - Public Methods
    
    public func refreshLibrary() {
        do {
            let files = try fileManager.contentsOfDirectory(
                at: libraryDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            articles = try jsonFiles.compactMap { url in
                guard let metadata = try? fileManager.attributesOfItem(atPath: url.path),
                      let modifiedDate = metadata[.modificationDate] as? Date else {
                    return nil
                }
                
                let data = try Data(contentsOf: url)
                let document = try JSONDecoder().decode(ArticleDocument.self, from: data)
                
                return ArticleMetadata(
                    title: document.title,
                    url: url,
                    modified: modifiedDate
                )
            }.sorted { $0.modified > $1.modified }
            
        } catch {
            print("❌ Ошибка загрузки библиотеки: \(error)")
            articles = []
        }
    }
    
    public func createNewArticle() -> ArticleMetadata? {
        let timestamp = Date().timeIntervalSince1970
        let fileName = "article_\(Int(timestamp)).json"
        let fileURL = libraryDirectory.appendingPathComponent(fileName)
        
        let newDocument = ArticleDocument(
            title: "Новая статья",
            sections: [],
            url: fileURL
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(newDocument)
            try data.write(to: fileURL)
            
            let metadata = ArticleMetadata(
                title: newDocument.title,
                url: fileURL,
                modified: Date()
            )
            
            articles.insert(metadata, at: 0)
            return metadata
            
        } catch {
            print("❌ Ошибка создания новой статьи: \(error)")
            return nil
        }
    }
    
    public func deleteArticle(at offsets: IndexSet) {
        for index in offsets {
            let article = articles[index]
            do {
                try fileManager.removeItem(at: article.url)
                articles.remove(at: index)
                print("✅ Статья удалена: \(article.title)")
            } catch {
                print("❌ Ошибка удаления статьи: \(error)")
            }
        }
    }
    
    // MARK: - macOS Only Import
    
    #if canImport(AppKit)
    public func importArticle() -> ArticleDocument? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Импорт статьи в библиотеку"
        openPanel.message = "Выберите JSON файл статьи для добавления в библиотеку"
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                let data = try Data(contentsOf: url)
                let importedDocument = try JSONDecoder().decode(ArticleDocument.self, from: data)
                
                let fileName = "imported_\(Date().timeIntervalSince1970).json"
                let libraryURL = libraryDirectory.appendingPathComponent(fileName)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
                let newData = try encoder.encode(importedDocument)
                try newData.write(to: libraryURL)
                
                refreshLibrary()
                
                print("✅ Статья импортирована в библиотеку: \(importedDocument.title)")
                showImportSuccessAlert(importedDocument.title)
                
                return ArticleDocument(
                    title: importedDocument.title,
                    sections: importedDocument.sections,
                    url: libraryURL
                )
            } catch {
                print("❌ Ошибка импорта в библиотеку: \(error)")
                showImportErrorAlert(error)
                return nil
            }
        }
        return nil
    }
    
    private func showImportSuccessAlert(_ title: String) {
        let alert = NSAlert()
        alert.messageText = "Статья импортирована в библиотеку"
        alert.informativeText = "\"\(title)\" успешно добавлена"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showImportErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Ошибка импорта"
        alert.informativeText = "Не удалось импортировать статью: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    #endif
    
    // MARK: - Private Methods
    
    private func getLibraryDirectory() -> URL {
        return libraryDirectory
    }
}
