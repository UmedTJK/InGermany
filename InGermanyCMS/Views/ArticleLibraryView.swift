import SwiftUI
import ArticleKit

public struct ArticleLibraryView: View {
    @StateObject private var viewModel: ArticleLibraryViewModel
    @State private var showingTemplatePicker = false
    
    let onOpenArticle: (ArticleDocument) -> Void

    public init(viewModel: ArticleLibraryViewModel, onOpenArticle: @escaping (ArticleDocument) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onOpenArticle = onOpenArticle
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.getArticlesForDisplay().isEmpty {
                    emptyStateView
                } else {
                    articlesListView
                }
            }
            .navigationTitle("Библиотека статей")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    // Search Field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Поиск статей...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(width: 200)
                        
                        if viewModel.searchIsActive {
                            Button("Отмена") {
                                viewModel.clearSearch()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // New Article Menu
                    Menu {
                        Button {
                            createNewArticle()
                        } label: {
                            Label("Пустая статья", systemImage: "doc")
                        }
                        
                        Button {
                            showingTemplatePicker = true
                        } label: {
                            Label("Из шаблона", systemImage: "square.grid.2x2")
                        }
                        
                        // Quick templates
                        Divider()
                        
                        ForEach([ArticleTemplate].defaultTemplates.prefix(3), id: \.id) { template in
                            Button {
                                createArticleFromTemplate(template)
                            } label: {
                                Label(template.name, systemImage: template.iconName)
                            }
                        }
                    } label: {
                        Label("Новая статья", systemImage: "plus")
                    }
                    
                    // Import Button
                    Button {
                        if let importedDocument = viewModel.importArticle() {
                            onOpenArticle(importedDocument)
                        }
                    } label: {
                        Label("Импорт", systemImage: "square.and.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.refreshLibrary()
                    } label: {
                        Label("Обновить", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshLibrary()
        }
        .sheet(isPresented: $showingTemplatePicker) {
            TemplatePickerView { document in
                onOpenArticle(document)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            if viewModel.searchIsActive {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("Статьи не найдены")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Попробуйте изменить поисковый запрос")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Очистить поиск") {
                    viewModel.clearSearch()
                }
                .buttonStyle(.bordered)
            } else {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("Пока нет статей")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Создайте первую статью чтобы начать работу")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Enhanced empty state with template options
                VStack(spacing: 12) {
                    Button("Создать пустую статью") {
                        createNewArticle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Выбрать из шаблонов") {
                        showingTemplatePicker = true
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var articlesListView: some View {
        VStack(spacing: 0) {
            // Search Results Info
            if viewModel.searchIsActive {
                HStack {
                    Text(viewModel.getArticleCountText())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Очистить") {
                        viewModel.clearSearch()
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
            }
            
            // Articles List
            List {
                ForEach(viewModel.getArticlesForDisplay()) { article in
                    articleRowView(article)
                        .contextMenu {
                            Button("Открыть") {
                                loadAndOpenArticle(article)
                            }
                            
                            Button("Дублировать") {
                                duplicateArticle(article)
                            }
                            
                            Divider()
                            
                            Button("Удалить", role: .destructive) {
                                viewModel.deleteArticle(article)
                            }
                        }
                }
                .onDelete(perform: viewModel.deleteArticle)
            }
        }
    }
    
    private func articleRowView(_ article: ArticleLibraryViewModel.ArticleMetadata) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title.isEmpty ? "Без названия" : article.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !article.contentPreview.isEmpty {
                    Text(article.contentPreview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(article.modified, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("изменено")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button("Открыть") {
                loadAndOpenArticle(article)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            loadAndOpenArticle(article)
        }
    }
    
    private func createNewArticle() {
        if let newArticle = viewModel.createNewArticle() {
            let newDocument = ArticleDocument(
                title: newArticle.title,
                sections: [
                    ArticleSectionDTO(
                        type: "paragraph",
                        content: "Начните писать вашу статью здесь..."
                    )
                ],
                url: newArticle.url
            )
            onOpenArticle(newDocument)
        }
    }
    
    private func createArticleFromTemplate(_ template: ArticleTemplate) {
        if let newArticle = viewModel.createNewArticle() {
            let templateDocument = ArticleDocument(
                title: template.name,
                sections: template.blocks.map { $0.toSectionDTO() },
                url: newArticle.url
            )
            
            // Сохраняем документ с контентом из шаблона
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(templateDocument)
                try data.write(to: newArticle.url)
                
                onOpenArticle(templateDocument)
            } catch {
                print("❌ Ошибка создания статьи из шаблона: \(error)")
                // Fallback - открываем пустой документ
                onOpenArticle(ArticleDocument(
                    title: template.name,
                    sections: template.blocks.map { $0.toSectionDTO() },
                    url: newArticle.url
                ))
            }
        }
    }
    
    private func duplicateArticle(_ article: ArticleLibraryViewModel.ArticleMetadata) {
        do {
            let data = try Data(contentsOf: article.url)
            let originalDocument = try JSONDecoder().decode(ArticleDocument.self, from: data)
            
            let timestamp = Date().timeIntervalSince1970
            let fileName = "\(article.title)_копия_\(Int(timestamp)).json"
            let fileURL = viewModel.getLibraryDirectory().appendingPathComponent(fileName)
            
            let duplicatedDocument = ArticleDocument(
                title: "\(article.title) (Копия)",
                sections: originalDocument.sections,
                url: fileURL
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let newData = try encoder.encode(duplicatedDocument)
            try newData.write(to: fileURL)
            
            viewModel.refreshLibrary()
            
        } catch {
            print("❌ Ошибка дублирования статьи: \(error)")
        }
    }
    
    private func loadAndOpenArticle(_ article: ArticleLibraryViewModel.ArticleMetadata) {
        do {
            let data = try Data(contentsOf: article.url)
            let document = try JSONDecoder().decode(ArticleDocument.self, from: data)
            onOpenArticle(document)
        } catch {
            print("⚠️ Не удалось загрузить статью: \(error)")
            // Создаем новый документ если не удалось загрузить
            let newDocument = ArticleDocument(
                title: article.title,
                sections: [],
                url: article.url
            )
            onOpenArticle(newDocument)
        }
    }
}

// MARK: - Preview
#Preview {
    ArticleLibraryView(viewModel: ArticleLibraryViewModel()) { document in
        print("Opening article: \(document.title)")
    }
}
