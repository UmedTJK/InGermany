import SwiftUI
import ArticleKit
import UniformTypeIdentifiers


// Модель данных для ссылки
struct LinkData {
    var url: String
    var title: String
    var isValid: Bool
    var domain: String?
    
    init(url: String = "", title: String = "") {
        self.url = url
        self.title = title
        self.isValid = false
        self.domain = nil
        validateURL()
    }
    
    mutating func validateURL() {
        // Базовая валидация URL
        let urlPattern = #"^https?://[^\s/$.?#].[^\s]*$"#
        let isValidFormat = url.range(of: urlPattern, options: .regularExpression) != nil
        
        if isValidFormat, let urlComponents = URL(string: url) {
            self.isValid = true
            self.domain = urlComponents.host
        } else {
            self.isValid = false
            self.domain = nil
        }
    }
}

struct BlockEditor: View {
    @Binding var block: ArticleBlock
    @State private var urlText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок типа блока
            Text(block.type.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Редактор в зависимости от типа блока
            switch block.type {
            case .paragraph, .info, .warning, .tip, .quote:
                textBlockEditor
            case .checklist, .list:
                listBlockEditor
            case .faq:
                faqBlockEditor
            case .links:
                linksBlockEditor
            case .image:
                imageBlockEditor
            }
        }
        .onAppear {
            // Инициализируем urlText при появлении
            urlText = block.content
        }
    }
    
    // MARK: - Специфичные редакторы
    
    private var textBlockEditor: some View {
        TextEditor(text: $block.content)
            .frame(minHeight: 120)
            .font(.body)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var listBlockEditor: some View {
        VStack(alignment: .leading) {
            ForEach(Array(block.items.enumerated()), id: \.element.id) { index, _ in
                HStack {
                    if block.type == .checklist {
                        Image(systemName: block.items[index].isCompleted ?? false ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                block.items[index].isCompleted = !(block.items[index].isCompleted ?? false)
                            }
                    }
                    
                    TextField("Элемент списка", text: Binding(
                        get: { block.items[index].text },
                        set: { block.items[index].text = $0 }
                    ))
                    
                    Button("Удалить") {
                        block.items.remove(at: index)
                    }
                    .foregroundColor(.red)
                }
            }
            
            Button("Добавить элемент") {
                let newItem = ArticleItemDTO(
                    text: "Новый элемент",
                    isCompleted: block.type == .checklist ? false : nil
                )
                block.items.append(newItem)
            }
        }
    }
    
    private var faqBlockEditor: some View {
        VStack(alignment: .leading) {
            TextField("Вопрос", text: $block.content)
                .font(.headline)
            
            if !block.items.isEmpty {
                TextEditor(text: Binding(
                    get: { block.items[0].text },
                    set: { block.items[0].text = $0 }
                ))
                .frame(minHeight: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            } else {
                Button("Добавить ответ") {
                    block.items.append(ArticleItemDTO(text: ""))
                }
            }
        }
    }
    
    private var linksBlockEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            Text("Ссылка")
                .font(.headline)
            
            // Поле URL с валидацией
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("URL")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Индикатор валидности
                    if !urlText.isEmpty {
                        Image(systemName: isLinkValid(urlText) ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isLinkValid(urlText) ? .green : .red)
                    }
                }
                
                TextField("https://example.com", text: $urlText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: urlText) { oldValue, newValue in
                        // Автоматическое добавление протокола если нужно
                        if !newValue.isEmpty && !newValue.hasPrefix("http") {
                            DispatchQueue.main.async {
                                let correctedURL = "https://" + newValue
                                urlText = correctedURL
                                block.content = correctedURL
                            }
                        } else {
                            block.content = newValue
                        }
                    }
                
                // Отображение домена
                if let domain = extractDomain(from: urlText) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(domain)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            
            // Поле заголовка ссылки
            VStack(alignment: .leading, spacing: 8) {
                Text("Заголовок ссылки")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Описание ссылки", text: Binding(
                    get: {
                        if block.items.isEmpty {
                            return ""
                        } else {
                            return block.items[0].text
                        }
                    },
                    set: {
                        if block.items.isEmpty {
                            block.items.append(ArticleItemDTO(text: $0))
                        } else {
                            block.items[0].text = $0
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Кнопка тестирования ссылки
            if isLinkValid(urlText) {
                Button(action: {
                    testLink(urlText)
                }) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Открыть в браузере")
                        Spacer()
                    }
                }
                .buttonStyle(.bordered)
            }
            
            // Визуальная подсказка для пользователя
            if !urlText.isEmpty && !isLinkValid(urlText) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                    Text("Введите корректный URL (начинается с http:// или https://)")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // ✅ ОБНОВЛЕННЫЙ РЕДАКТОР ИЗОБРАЖЕНИЙ
    private var imageBlockEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            Text("Изображение")
                .font(.headline)
            
            // Область загрузки изображения
            imageUploadSection
            
            // Поля для подписи и альтернативного текста
            VStack(alignment: .leading, spacing: 12) {
                Text("Подпись к изображению")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Введите подпись...", text: Binding(
                    get: { block.imageData?.caption ?? "" },
                    set: {
                        if block.imageData == nil {
                            block.imageData = ImageData(caption: $0)
                        } else {
                            block.imageData?.caption = $0
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Альтернативный текст (для доступности)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Описание изображения для скринридеров...", text: Binding(
                    get: { block.imageData?.altText ?? "" },
                    set: {
                        if block.imageData == nil {
                            block.imageData = ImageData(altText: $0)
                        } else {
                            block.imageData?.altText = $0
                        }
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // ✅ СЕКЦИЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЯ
    private var imageUploadSection: some View {
        VStack(spacing: 12) {
            if let imagePath = block.imageData?.imagePath,
               let image = loadImage(from: imagePath) {
                // Превью выбранного изображения
                VStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                    
                    HStack {
                        Text("Выбрано: \((imagePath as NSString).lastPathComponent)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Удалить") {
                            block.imageData?.imagePath = nil
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                    }
                }
            } else {
                // Кнопка выбора изображения
                Button(action: selectImage) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("Выберите изображение")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Нажмите чтобы выбрать файл")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Вспомогательные функции для редактора ссылок
    
    private func isLinkValid(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme?.hasPrefix("http") == true && url.host != nil
    }
    
    private func extractDomain(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.host
    }
    
    private func testLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    // ✅ ФУНКЦИЯ ВЫБОРА ИЗОБРАЖЕНИЯ
    private func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            // Сохраняем путь к файлу
            if block.imageData == nil {
                block.imageData = ImageData(imagePath: url.path)
            } else {
                block.imageData?.imagePath = url.path
            }
        }
    }
    
    // ✅ ФУНКЦИЯ ЗАГРУЗКИ ИЗОБРАЖЕНИЯ ДЛЯ ПРЕВЬЮ
    private func loadImage(from path: String) -> Image? {
        guard let nsImage = NSImage(contentsOfFile: path) else { return nil }
        return Image(nsImage: nsImage)
    }
}
