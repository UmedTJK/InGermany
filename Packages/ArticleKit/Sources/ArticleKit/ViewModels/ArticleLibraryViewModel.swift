import SwiftUI
import Foundation
import Combine

#if canImport(AppKit)
import AppKit
#endif

public class ArticleLibraryViewModel: ObservableObject {
    @Published public var articles: [ArticleMetadata] = []
    
    // Search functionality
    @Published public var searchText: String = ""
    @Published public private(set) var filteredArticles: [ArticleMetadata] = []
    @Published public var searchIsActive: Bool = false
    
    private let fileManager = FileManager.default
    private let libraryDirectory: URL
    private var cancellables = Set<AnyCancellable>()
    private var allArticles: [ArticleMetadata] = []
    
    public struct ArticleMetadata: Identifiable {
        public let id = UUID()
        public let title: String
        public let url: URL
        public let modified: Date
        public let contentPreview: String
        
        public init(title: String, url: URL, modified: Date, contentPreview: String = "") {
            self.title = title
            self.url = url
            self.modified = modified
            self.contentPreview = contentPreview
        }
    }
    
    public init() {
        // Определяем директорию для библиотеки статей
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        libraryDirectory = documentsURL.appendingPathComponent("ArticleLibrary")
        
        // Создаем директорию если она не существует
        try? fileManager.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
        
        // Настраиваем поиск
        setupSearch()
        
        // Загружаем статьи при инициализации
        refreshLibrary()
    }
    
    // MARK: - Search Setup
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] searchText -> [ArticleMetadata] in
                guard let self = self else { return [] }
                
                if searchText.isEmpty {
                    return self.allArticles
                }
                
                let lowercasedSearch = searchText.lowercased()
                return self.allArticles.filter { article in
                    article.title.lowercased().contains(lowercasedSearch) ||
                    article.contentPreview.lowercased().contains(lowercasedSearch)
                }
            }
            .assign(to: &$filteredArticles)
            
        $searchText
            .map { !$0.isEmpty }
            .assign(to: &$searchIsActive)
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
            
            allArticles = try jsonFiles.compactMap { url in
                guard let metadata = try? fileManager.attributesOfItem(atPath: url.path),
                      let modifiedDate = metadata[.modificationDate] as? Date else {
                    return nil
                }
                
                let data = try Data(contentsOf: url)
                let document = try JSONDecoder().decode(ArticleDocument.self, from: data)
                
                // Создаем превью контента для поиска
                let contentPreview = document.sections
                    .prefix(3)
                    .compactMap { $0.content } // Добавьте compactMap для обработки опциональных значений
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                return ArticleMetadata(
                    title: document.title,
                    url: url,
                    modified: modifiedDate,
                    contentPreview: contentPreview
                )
            }.sorted { $0.modified > $1.modified }
            
            articles = allArticles
            filteredArticles = allArticles
            
        } catch {
            print("❌ Ошибка загрузки библиотеки: \(error)")
            articles = []
            allArticles = []
            filteredArticles = []
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
                modified: Date(),
                contentPreview: ""
            )
            
            allArticles.insert(metadata, at: 0)
            articles = allArticles
            
            // Обновляем отфильтрованные статьи если поиск не активен
            if !searchIsActive {
                filteredArticles = allArticles
            }
            
            return metadata
            
        } catch {
            print("❌ Ошибка создания новой статьи: \(error)")
            return nil
        }
    }
    
    public func deleteArticle(at offsets: IndexSet) {
        for index in offsets {
            let article = filteredArticles[index]
            do {
                try fileManager.removeItem(at: article.url)
                
                // Удаляем из всех массивов
                if let allIndex = allArticles.firstIndex(where: { $0.id == article.id }) {
                    allArticles.remove(at: allIndex)
                }
                if let articlesIndex = articles.firstIndex(where: { $0.id == article.id }) {
                    articles.remove(at: articlesIndex)
                }
                filteredArticles.remove(at: index)
                
                print("✅ Статья удалена: \(article.title)")
            } catch {
                print("❌ Ошибка удаления статьи: \(error)")
            }
        }
    }
    
    public func deleteArticle(_ article: ArticleMetadata) {
        do {
            try fileManager.removeItem(at: article.url)
            
            // Удаляем из всех массивов
            allArticles.removeAll { $0.id == article.id }
            articles.removeAll { $0.id == article.id }
            filteredArticles.removeAll { $0.id == article.id }
            
            print("✅ Статья удалена: \(article.title)")
        } catch {
            print("❌ Ошибка удаления статьи: \(error)")
        }
    }
    
    public func clearSearch() {
        searchText = ""
    }
    
    public func getArticlesForDisplay() -> [ArticleMetadata] {
        return searchIsActive ? filteredArticles : articles
    }
    
    public func getArticleCountText() -> String {
        let totalCount = articles.count
        let displayCount = getArticlesForDisplay().count
        
        if searchIsActive && displayCount != totalCount {
            return "\(displayCount) из \(totalCount) статей"
        } else {
            return "\(totalCount) \(pluralizeArticles(totalCount))"
        }
    }
    
    private func pluralizeArticles(_ count: Int) -> String {
        let remainder = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 19 {
            return "статей"
        }
        
        switch remainder {
        case 1:
            return "статья"
        case 2...4:
            return "статьи"
        default:
            return "статей"
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
    
    public func getLibraryDirectory() -> URL {
        return libraryDirectory
    }
}

// MARK: - ArticleDocument Extension for Search
extension ArticleDocument {
    var searchableContent: String {
        return sections.compactMap { $0.content }.joined(separator: " ") // Добавьте compactMap
    }
    
    func matchesSearch(_ searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        return title.lowercased().contains(lowercasedSearch) ||
               searchableContent.lowercased().contains(lowercasedSearch)
    }
}
