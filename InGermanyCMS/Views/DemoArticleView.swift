import SwiftUI
import ArticleKit

/// Demo screen that loads a JSON article from the app bundle and renders it with ArticleRenderer.
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
        
        // 1. Проверим Bundle.main
        print("📦 Bundle.main.bundlePath: \(Bundle.main.bundlePath)")
        
        // 2. Проверим все ресурсы
        if let resourcePath = Bundle.main.resourcePath {
            print("📁 Resource path: \(resourcePath)")
            let fm = FileManager.default
            if let files = try? fm.contentsOfDirectory(atPath: resourcePath) {
                print("📋 Файлы в Resources:")
                for file in files.sorted() {
                    print("   - \(file)")
                }
            }
        }
        
        // 3. Попробуем найти файл разными способами
        guard let url = Bundle.main.url(forResource: "burgeramt_registration", withExtension: "json") else {
            isLoading = false
            let error = "Файл burgeramt_registration.json не найден в Resources"
            print("❌ \(error)")
            loadError = error
            return
        }
        
        print("✅ Файл найден по пути: \(url.path)")
        
        do {
            // 4. Проверим доступность файла
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            print("📄 Файл существует: \(fileExists)")
            
            let data = try Data(contentsOf: url)
            print("✅ Данные прочитаны: \(data.count) байт")
            
            // 5. Попробуем посмотреть содержимое
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📝 Первые 200 символов JSON:")
                let preview = String(jsonString.prefix(200))
                print("   \(preview)...")
            }
            
            // 6. Декодируем
            sections = try JSONDecoder().decode([ArticleSectionDTO].self, from: data)
            print("🎉 Успешно декодировано: \(sections.count) секций")
            isLoading = false
            
        } catch {
            let errorDescription = "Ошибка: \(error.localizedDescription)\nДетали: \(error)"
            print("❌ \(errorDescription)")
            loadError = errorDescription
            isLoading = false
        }
    }
}
