//
//  ArticleTemplates.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//
//
//  ArticleTemplates.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//

import Foundation

public struct ArticleTemplate: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String
    public let iconName: String
    public let blocks: [ArticleBlock]
    public let category: TemplateCategory
    public let tags: [String]
    public let estimatedTime: Int // В минутах
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        blocks: [ArticleBlock],
        category: TemplateCategory,
        tags: [String] = [],
        estimatedTime: Int = 5
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.blocks = blocks
        self.category = category
        self.tags = tags
        self.estimatedTime = estimatedTime
    }
    
    // Добавляем ручную реализацию Hashable
    public static func == (lhs: ArticleTemplate, rhs: ArticleTemplate) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum TemplateCategory: String, CaseIterable, Codable {
    case basic = "basic"
    case guide = "guide"
    case checklist = "checklist"
    case faq = "faq"
    case custom = "custom"
    
    public var displayName: String {
        switch self {
        case .basic: return "Базовые"
        case .guide: return "Руководства"
        case .checklist: return "Чек-листы"
        case .faq: return "Вопрос-ответ"
        case .custom: return "Пользовательские"
        }
    }
    
    public var iconName: String {
        switch self {
        case .basic: return "doc.text"
        case .guide: return "book"
        case .checklist: return "checklist"
        case .faq: return "questionmark.circle"
        case .custom: return "star"
        }
    }
    
    public var color: String {
        switch self {
        case .basic: return "blue"
        case .guide: return "green"
        case .checklist: return "orange"
        case .faq: return "purple"
        case .custom: return "yellow"
        }
    }
}

// MARK: - Default Templates Data
extension ArticleTemplate {
    public static var empty: ArticleTemplate {
        ArticleTemplate(
            name: "Пустая статья",
            description: "Начните с чистого листа",
            iconName: "doc",
            blocks: [],
            category: .basic,
            tags: ["базовый", "пустой"],
            estimatedTime: 1
        )
    }
    
    public static var stepByStepGuide: ArticleTemplate {
        ArticleTemplate(
            name: "Пошаговое руководство",
            description: "Структура для обучающих материалов",
            iconName: "book",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Введение\n\nОпишите цель этого руководства и что читатель узнает по его завершении."),
                ArticleBlock(type: .info, content: "Это руководство поможет вам шаг за шагом освоить процесс. Следуйте инструкциям последовательно."),
                ArticleBlock(type: .paragraph, content: "## Что вам понадобится\n\n- Первый необходимый элемент\n- Второй необходимый элемент\n- Третий необходимый элемент"),
                ArticleBlock(type: .paragraph, content: "## Шаг 1: Начало работы\n\nОпишите первый шаг процесса. Будьте максимально конкретны и понятны."),
                ArticleBlock(type: .paragraph, content: "## Шаг 2: Основной процесс\n\nОпишите следующий шаг. Добавьте детали и пояснения."),
                ArticleBlock(type: .tip, content: "Полезный совет для успешного завершения этого шага"),
                ArticleBlock(type: .paragraph, content: "## Шаг 3: Завершение\n\nОпишите финальные действия и проверку результата."),
                ArticleBlock(type: .warning, content: "Обратите внимание на возможные ошибки и как их избежать"),
                ArticleBlock(type: .paragraph, content: "## Заключение\n\nПодведите итоги и дайте рекомендации для следующих шагов.")
            ],
            category: .guide,
            tags: ["руководство", "обучение", "шаги"],
            estimatedTime: 15
        )
    }
    
    public static var checklist: ArticleTemplate {
        ArticleTemplate(
            name: "Чек-лист",
            description: "Список задач с отметками выполнения",
            iconName: "checklist",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Чек-лист\n\nПоставьте галочки напротив выполненных пунктов:"),
                ArticleBlock(type: .checklist, content: "Первая задача\nВторая задача\nТретья задача\nЧетвертая задача"),
                ArticleBlock(type: .tip, content: "Вы можете отмечать выполненные задачи в приложении")
            ],
            category: .checklist,
            tags: ["чеклист", "задачи", "продуктивность"],
            estimatedTime: 5
        )
    }
    
    public static var faq: ArticleTemplate {
        ArticleTemplate(
            name: "Часто задаваемые вопросы",
            description: "Структура вопрос-ответ",
            iconName: "questionmark.circle",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Часто задаваемые вопросы\n\nОтветы на самые популярные вопросы:"),
                ArticleBlock(type: .faq, content: "Какой первый вопрос?\nПодробный ответ на первый вопрос с объяснениями и примерами."),
                ArticleBlock(type: .faq, content: "Какой второй вопрос?\nРазвернутый ответ на второй вопрос, охватывающий все аспекты."),
                ArticleBlock(type: .faq, content: "Какой третий вопрос?\nПолный ответ на третий вопрос с дополнительными рекомендациями."),
                ArticleBlock(type: .info, content: "Если у вас остались вопросы, свяжитесь с нами для получения дополнительной помощи.")
            ],
            category: .faq,
            tags: ["вопросы", "ответы", "помощь"],
            estimatedTime: 10
        )
    }
    
    public static var articleWithImages: ArticleTemplate {
        ArticleTemplate(
            name: "Статья с иллюстрациями",
            description: "Для визуального контента с изображениями",
            iconName: "photo",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Заголовок статьи\n\nВведение с основными мыслями и целями статьи."),
                ArticleBlock(type: .image, content: "{\"imagePath\":\"\",\"caption\":\"Подпись к первому изображению\",\"altText\":\"Описание изображения для доступности\"}"),
                ArticleBlock(type: .paragraph, content: "Пояснения к изображению и продолжение основной мысли."),
                ArticleBlock(type: .image, content: "{\"imagePath\":\"\",\"caption\":\"Подпись ко второму изображению\",\"altText\":\"Описание второго изображения\"}"),
                ArticleBlock(type: .paragraph, content: "Дополнительные разъяснения и заключительные мысли."),
                ArticleBlock(type: .tip, content: "Используйте качественные изображения для лучшего восприятия контента")
            ],
            category: .guide,
            tags: ["изображения", "визуальный", "иллюстрации"],
            estimatedTime: 12
        )
    }
    
    public static var quickTips: ArticleTemplate {
        ArticleTemplate(
            name: "Советы и рекомендации",
            description: "Коллекция полезных советов",
            iconName: "lightbulb",
            blocks: [
                ArticleBlock(type: .paragraph, content: "## Полезные советы\n\nКоллекция проверенных рекомендаций:"),
                ArticleBlock(type: .tip, content: "Первый полезный совет с подробным объяснением"),
                ArticleBlock(type: .tip, content: "Второй практический совет для улучшения результата"),
                ArticleBlock(type: .tip, content: "Третий экспертный совет на основе опыта"),
                ArticleBlock(type: .warning, content: "Важное предупреждение о типичных ошибках"),
                ArticleBlock(type: .tip, content: "Финальный совет для закрепления результата")
            ],
            category: .guide,
            tags: ["советы", "рекомендации", "лайфхаки"],
            estimatedTime: 8
        )
    }
}

// MARK: - Helper Methods
extension ArticleTemplate {
    public var blocksCount: Int {
        return blocks.count
    }
    
    public var formattedTime: String {
        if estimatedTime < 60 {
            return "\(estimatedTime) мин"
        } else {
            let hours = estimatedTime / 60
            let minutes = estimatedTime % 60
            return minutes > 0 ? "\(hours)ч \(minutes)м" : "\(hours)ч"
        }
    }
    
    public func matchesSearch(_ searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        return name.lowercased().contains(lowercasedSearch) ||
               description.lowercased().contains(lowercasedSearch) ||
               tags.contains { $0.lowercased().contains(lowercasedSearch) } ||
               category.displayName.lowercased().contains(lowercasedSearch)
    }
}

// MARK: - Template Collection
extension Array where Element == ArticleTemplate {
    public static var defaultTemplates: [ArticleTemplate] {
        return [
            .empty,
            .stepByStepGuide,
            .checklist,
            .faq,
            .articleWithImages,
            .quickTips
        ]
    }
    
    public func filtered(by category: TemplateCategory) -> [ArticleTemplate] {
        return filter { $0.category == category }
    }
    
    public func search(_ searchText: String) -> [ArticleTemplate] {
        guard !searchText.isEmpty else { return self }
        return filter { $0.matchesSearch(searchText) }
    }
}

// MARK: - ArticleBlock Extension for Template Support
extension ArticleBlock {
    public static func fromTemplateContent(_ content: String) -> ArticleBlock {
        // Базовая реализация - можно расширить при необходимости
        return ArticleBlock(type: .paragraph, content: content)
    }
}
