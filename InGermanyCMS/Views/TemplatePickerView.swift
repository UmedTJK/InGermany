//
//  TemplatePickerView.swift
//  InGermany
//
//  Created by SUM TJK on 24.10.25.
//

import SwiftUI
import ArticleKit

public struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var templateService = ArticleTemplateService()
    @State private var selectedCategory: TemplateCategory = .basic
    @State private var showingCreateTemplate = false
    
    let onTemplateSelected: (ArticleDocument) -> Void
    
    public init(onTemplateSelected: @escaping (ArticleDocument) -> Void) {
        self.onTemplateSelected = onTemplateSelected
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                categoryPicker
                
                // Search Bar
                searchBar
                
                // Templates Grid
                templatesGrid
                
                // Footer Stats
                footerStats
            }
            .navigationTitle("Выберите шаблон")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Создать шаблон") {
                        showingCreateTemplate = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateTemplateView(templateService: templateService)
            }
        }
        .frame(width: 800, height: 600)
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(templateService.categories, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        templateCount: templateService.getTemplates(for: category).count,
                        onSelect: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Поиск шаблонов...", text: $templateService.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !templateService.searchText.isEmpty {
                Button("Очистить") {
                    templateService.clearSearch()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var templatesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16)
            ], spacing: 16) {
                ForEach(templateService.getTemplates(for: selectedCategory)) { template in
                    TemplateCard(
                        template: template,
                        onSelect: {
                            let document = templateService.createDocument(from: template)
                            onTemplateSelected(document)
                            dismiss()
                        },
                        onDuplicate: {
                            _ = templateService.duplicateTemplate(template)
                        },
                        onDelete: {
                            templateService.deleteTemplate(template)
                        }
                    )
                    .contextMenu {
                        Button("Дублировать") {
                            _ = templateService.duplicateTemplate(template) // Добавьте _ =
                        }
                        
                        if template.category == .custom {
                            Button("Удалить", role: .destructive) {
                                templateService.deleteTemplate(template)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var footerStats: some View {
        VStack(spacing: 4) {
            Divider()
            
            HStack {
                let stats = templateService.getTemplateStats()
                
                Text("\(stats.totalTemplates) шаблонов • \(stats.customTemplates) пользовательских")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !templateService.searchText.isEmpty {
                    Text("Найдено: \(templateService.filteredTemplates.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: TemplateCategory
    let isSelected: Bool
    let templateCount: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 14))
                
                Text(category.displayName)
                    .font(.subheadline)
                
                if templateCount > 0 {
                    Text("\(templateCount)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor)
    }
    
    private var foregroundColor: Color {
        isSelected ? .white : .primary
    }
    
    private var borderColor: Color {
        isSelected ? Color.accentColor : Color(NSColor.separatorColor)
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: ArticleTemplate
    let onSelect: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: template.iconName)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 32, height: 32)
                    
                    Spacer()
                    
                    // Badges
                    HStack(spacing: 4) {
                        if template.category == .custom {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("\(template.blocksCount) блоков")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Tags
                    if !template.tags.isEmpty {
                        FlowLayout(spacing: 4) {
                            ForEach(template.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Footer
                    HStack {
                        Text(template.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(template.category.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Template View (Placeholder)
struct CreateTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var templateService: ArticleTemplateService
    @State private var templateName = ""
    @State private var templateDescription = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Название шаблона", text: $templateName)
                TextField("Описание", text: $templateDescription)
            }
            .navigationTitle("Новый шаблон")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Создать") {
                        // Здесь будет логика создания шаблона
                        dismiss()
                    }
                    .disabled(templateName.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > proposal.width ?? 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return CGSize(width: proposal.width ?? 0, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Preview
#Preview {
    TemplatePickerView { document in
        print("Selected template: \(document.title)")
    }
}
