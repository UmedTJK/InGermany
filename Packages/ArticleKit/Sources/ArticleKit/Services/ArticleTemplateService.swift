//
//  ArticleTemplateService.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//

import Foundation
import Combine

public class ArticleTemplateService: ObservableObject {
    @Published public private(set) var templates: [ArticleTemplate] = []
    @Published public private(set) var categories: [TemplateCategory] = TemplateCategory.allCases
    @Published public var searchText: String = ""
    @Published public private(set) var filteredTemplates: [ArticleTemplate] = []
    
    private let userDefaultsKey = "savedCustomTemplates"
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadTemplates()
        setupSearch()
    }
    
    // MARK: - Public Methods
    
    public func getTemplates(for category: TemplateCategory) -> [ArticleTemplate] {
        let categoryTemplates = templates.filter { $0.category == category }
        return searchText.isEmpty ? categoryTemplates : categoryTemplates.search(searchText)
    }
    
    public func createDocument(from template: ArticleTemplate) -> ArticleDocument {
        return ArticleDocument(
            title: template.name,
            sections: template.blocks.map { $0.toSectionDTO() }
        )
    }
    
    public func saveCustomTemplate(_ template: ArticleTemplate) {
        // Проверяем, нет ли уже шаблона с таким ID
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
        } else {
            templates.append(template)
        }
        saveCustomTemplatesToUserDefaults()
    }
    
    public func deleteTemplate(_ template: ArticleTemplate) {
        templates.removeAll { $0.id == template.id }
        saveCustomTemplatesToUserDefaults()
    }
    
    public func createCustomTemplate(
        name: String,
        description: String,
        blocks: [ArticleBlock],
        category: TemplateCategory = .custom,
        tags: [String] = []
    ) -> ArticleTemplate {
        let template = ArticleTemplate(
            name: name,
            description: description,
            iconName: category.iconName,
            blocks: blocks,
            category: category,
            tags: tags
        )
        saveCustomTemplate(template)
        return template
    }
    
    public func duplicateTemplate(_ template: ArticleTemplate) -> ArticleTemplate {
        let duplicated = ArticleTemplate(
            name: "\(template.name) (Копия)",
            description: template.description,
            iconName: template.iconName,
            blocks: template.blocks,
            category: template.category,
            tags: template.tags,
            estimatedTime: template.estimatedTime
        )
        saveCustomTemplate(duplicated)
        return duplicated
    }
    
    public func clearSearch() {
        searchText = ""
    }
    
    public func hasTemplates(in category: TemplateCategory) -> Bool {
        return !getTemplates(for: category).isEmpty
    }
    
    public func getTemplateStats() -> TemplateStats {
        let totalTemplates = templates.count
        let defaultTemplatesCount = templates.filter { $0.category != .custom }.count
        let customTemplatesCount = templates.filter { $0.category == .custom }.count
        
        let totalBlocks = templates.reduce(0) { $0 + $1.blocks.count }
        let averageBlocks = totalTemplates > 0 ? totalBlocks / totalTemplates : 0
        
        return TemplateStats(
            totalTemplates: totalTemplates,
            defaultTemplates: defaultTemplatesCount,
            customTemplates: customTemplatesCount,
            totalBlocks: totalBlocks,
            averageBlocks: averageBlocks
        )
    }
    
    // MARK: - Private Methods
    
    private func loadTemplates() {
        // Загружаем стандартные шаблоны
        templates = .defaultTemplates
        
        // Загружаем пользовательские шаблоны
        loadCustomTemplatesFromUserDefaults()
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] searchText -> [ArticleTemplate] in
                guard let self = self else { return [] }
                
                if searchText.isEmpty {
                    return self.templates
                }
                
                return self.templates.search(searchText)
            }
            .assign(to: &$filteredTemplates)
    }
    
    private func saveCustomTemplatesToUserDefaults() {
        let customTemplates = templates.filter { $0.category == .custom }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customTemplates)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            print("✅ Пользовательские шаблоны сохранены: \(customTemplates.count) шт.")
        } catch {
            print("❌ Ошибка сохранения пользовательских шаблонов: \(error)")
        }
    }
    
    private func loadCustomTemplatesFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("ℹ️ Пользовательские шаблоны не найдены")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let customTemplates = try decoder.decode([ArticleTemplate].self, from: data)
            
            // Удаляем старые пользовательские шаблоны и добавляем новые
            templates.removeAll { $0.category == .custom }
            templates.append(contentsOf: customTemplates)
            
            print("✅ Пользовательские шаблоны загружены: \(customTemplates.count) шт.")
        } catch {
            print("❌ Ошибка загрузки пользовательских шаблонов: \(error)")
            // В случае ошибки удаляем поврежденные данные
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }
}

// MARK: - Template Stats
public struct TemplateStats {
    public let totalTemplates: Int
    public let defaultTemplates: Int
    public let customTemplates: Int
    public let totalBlocks: Int
    public let averageBlocks: Int
    
    public var customTemplatesPercentage: Double {
        guard totalTemplates > 0 else { return 0 }
        return Double(customTemplates) / Double(totalTemplates) * 100
    }
}

// MARK: - Preview Data Extension
#if DEBUG
extension ArticleTemplateService {
    public static var preview: ArticleTemplateService {
        let service = ArticleTemplateService()
        return service
    }
    
    public func addPreviewCustomTemplates() {
        let customTemplate1 = ArticleTemplate(
            name: "Мой рабочий процесс",
            description: "Персональный шаблон для ежедневных задач",
            iconName: "gear",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Ежедневные задачи\n\nСписок обязательных действий на день:"),
                ArticleBlock(type: .checklist, content: "Проверить почту\nСоставить план на день\nВыполнить основные задачи\nПодвести итоги")
            ],
            category: .custom,
            tags: ["работа", "ежедневно", "план"]
        )
        
        let customTemplate2 = ArticleTemplate(
            name: "Обзор проекта",
            description: "Шаблон для описания и анализа проектов",
            iconName: "folder",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Обзор проекта\n\nКраткое описание целей и задач проекта."),
                ArticleBlock(type: .paragraph, content: "## Основные этапы\n\n- Подготовительный этап\n- Основная реализация\n- Тестирование\n- Завершение"),
                ArticleBlock(type: .info, content: "Сроки и бюджет проекта должны быть согласованы заранее")
            ],
            category: .custom,
            tags: ["проект", "анализ", "планирование"]
        )
        
        saveCustomTemplate(customTemplate1)
        saveCustomTemplate(customTemplate2)
    }
}
#endif
