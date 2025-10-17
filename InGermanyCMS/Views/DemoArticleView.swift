import SwiftUI
import ArticleKit

/// Demo screen that loads a JSON article from the app bundle and renders it with ArticleRenderer.
public struct DemoArticleView: View {
    @State private var sections: [ArticleSectionDTO] = []
    @State private var loadError: String?
    @State private var isLoading: Bool = true

    // Упрощенный инициализатор без зависимостей
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    // Простая замена LoadingView
                    ProgressView("Загрузка...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let loadError = loadError {
                    Text("Ошибка загрузки JSON:\n\(loadError)")
                        .font(.callout)
                        .foregroundColor(.red)
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
            .navigationTitle("Demo Article") // Упростили без LocalizationManager
        }
        .onAppear {
            loadDemoArticle()
        }
    }

    private func loadDemoArticle() {
        isLoading = true
        loadError = nil

        guard let url = Bundle.main.url(forResource: "burgeramt_registration",
                                        withExtension: "json") else {
            isLoading = false
            loadError = "Файл burgeramt_registration.json не найден в Resources"
            return
        }

        do {
            let data = try Data(contentsOf: url)
            sections = try JSONDecoder().decode([ArticleSectionDTO].self, from: data)
            isLoading = false
        } catch {
            loadError = error.localizedDescription
            isLoading = false
        }
    }
}
