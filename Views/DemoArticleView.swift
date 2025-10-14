import SwiftUI

/// Demo screen that loads a JSON article from the app bundle and renders it with ArticleRenderer.
struct DemoArticleView: View {
    @State private var sections: [ArticleSectionDTO] = []   // ✅ используем DTO
    @State private var loadError: String?
    @State private var isLoading: Bool = true

    private let localizationManager: LocalizationManager

    // MARK: - Init через DI
    init(localizationManager: LocalizationManager) {
        self.localizationManager = localizationManager
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoading {
                    LoadingView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let loadError {
                    Text("Ошибка загрузки JSON:\n\(loadError)")
                        .font(.callout)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if !sections.isEmpty {
                    ArticleRenderer(sections: sections)   // ✅ работает с ArticleSectionDTO
                } else {
                    Text("Нет данных для отображения")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle(localizationManager.t("demo_article_title"))
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
            // ✅ декодим сразу в ArticleSectionDTO
            sections = try JSONDecoder().decode([ArticleSectionDTO].self, from: data)
            isLoading = false
        } catch {
            loadError = error.localizedDescription
            isLoading = false
        }
    }
}
