import SwiftUI
import ArticleKit

public struct DemoArticleView: View {
    @State private var sections: [ArticleSectionDTO] = []
    @State private var loadError: String?
    @State private var isLoading: Bool = true

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let loadError = loadError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ошибка загрузки JSON:")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(loadError)
                            .font(.body)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if !sections.isEmpty {
                    ArticleRenderer(sections: sections)
                } else {
                    Text("Нет данных для отображения")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Demo Article")
        }
        .onAppear {
            loadDemoArticle()
        }
    }

    private func loadDemoArticle() {
        isLoading = true
        loadError = nil
        
        print("🔍 Начинаем загрузку демо статьи...")
        
        // Создаем демо-статью программно вместо загрузки из JSON
        createDemoArticle()
    }
    
    private func createDemoArticle() {
        // Создаем демо-статью с правильной структурой
        sections = [
            ArticleSectionDTO(
                type: "paragraph",
                content: "Добро пожаловать в демо-статью! Это пример того, как работает ArticleRenderer."
            ),
            ArticleSectionDTO(
                type: "info",
                content: "Это информационный блок с полезной информацией."
            ),
            ArticleSectionDTO(
                type: "warning",
                content: "Это предупреждающий блок для важных уведомлений."
            ),
            ArticleSectionDTO(
                type: "tip",
                content: "А это полезный совет для пользователей."
            ),
            ArticleSectionDTO(
                type: "checklist",
                items: [
                    ArticleItemDTO(text: "Изучить SwiftUI", isCompleted: true),
                    ArticleItemDTO(text: "Разработать редактор статей", isCompleted: true),
                    ArticleItemDTO(text: "Добавить новые функции", isCompleted: false)
                ]
            ),
            ArticleSectionDTO(
                type: "list",
                items: [
                    ArticleItemDTO(text: "Первый элемент списка"),
                    ArticleItemDTO(text: "Второй элемент списка"),
                    ArticleItemDTO(text: "Третий элемент списка")
                ]
            ),
            ArticleSectionDTO(
                type: "faq",
                content: "Как работает этот редактор?",
                items: [
                    ArticleItemDTO(text: "Это визуальный редактор для создания статей с различными типами блоков.")
                ]
            )
        ]
        
        isLoading = false
        print("✅ Демо-статья создана: \(sections.count) секций")
    }
}
