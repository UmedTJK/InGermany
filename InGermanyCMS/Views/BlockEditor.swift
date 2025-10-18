import SwiftUI
import ArticleKit

struct BlockEditor: View {
    @Binding var block: ArticleBlock
    
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
        Text("Редактор ссылок - в разработке")
            .foregroundColor(.secondary)
    }
    
    private var imageBlockEditor: some View {
        Text("Редактор изображений - в разработке")
            .foregroundColor(.secondary)
    }
}
