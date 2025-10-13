//
//  ArticleEditorView.swift
//  InGermany
//

import SwiftUI

struct ArticleEditorView: View {
    @StateObject private var viewModel: ArticleEditorViewModel
    @State private var showPicker = false
    @State private var showDeleteAlertFor: UUID?

    init(viewModel: ArticleEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Title")) {
                        TextField("Enter title", text: $viewModel.title)
                            .textInputAutocapitalization(.sentences)
                    }

                    Section(header: HStack {
                        Text("Blocks")
                        Spacer()
                        EditButton()
                    }) {
                        if viewModel.blocks.isEmpty {
                            Text("No blocks yet").foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.blocks) { block in
                                blockEditor(for: block)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            showDeleteAlertFor = block.id
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                            .onMove(perform: viewModel.moveBlock)
                        }
                    }

                    // 🆕 Live Preview
                    Section(header: Text("Preview")) {
                        ArticleRenderer(sections: viewModel.toSections())
                            .frame(minHeight: 200)
                    }
                }

                // Bottom toolbar
                HStack {
                    Button {
                        showPicker = true
                    } label: {
                        Label("Add Block", systemImage: "plus.circle")
                    }

                    Spacer()

                    Button {
                        do {
                            let _ = try viewModel.exportToJSON()
                        } catch {
                            print("Export error: \(error)")
                        }
                    } label: {
                        Label("Export JSON", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        if let fileURL = viewModel.exportedFileURL() {
                            let av = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let root = scene.windows.first?.rootViewController {
                                root.present(av, animated: true, completion: nil)
                            }
                        }
                    } label: {
                        Label("Share JSON", systemImage: "square.and.arrow.up.on.square")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

            }
            .navigationTitle("Article Editor")
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    BlockPickerView { type in
                        viewModel.addBlock(type: type)
                        showPicker = false
                    }
                }
            }
            .alert("Delete block?", isPresented: Binding(get: { showDeleteAlertFor != nil },
                                                        set: { if !$0 { showDeleteAlertFor = nil } })) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let id = showDeleteAlertFor {
                        viewModel.deleteBlock(id: id)
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    // MARK: - Per-Block Editors
    @ViewBuilder
    private func blockEditor(for block: ArticleBlock) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(block.type.rawValue.capitalized)
                .font(.headline)

            switch block.payload {
            case .content(let text):
                TextEditor(text: bindingContent(for: block.id, original: text))
                    .frame(minHeight: 80)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))

            case .list(let items):
                listEditor(blockID: block.id, items: items)

            case .checklist(let entries):
                checklistEditor(blockID: block.id, entries: entries)

            case .faq(let q, let a):
                faqEditor(blockID: block.id, q: q, a: a)

            case .links(let links):
                linksEditor(blockID: block.id, links: links)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Вспомогательные редакторы и биндинги (оставляем всё как у тебя было!)
    // сюда идут твои listEditor, checklistEditor, faqEditor, linksEditor,
    // bindingContent, updateListItem, updateChecklistText и т.д.



    // MARK: - Per-Block Editors



    // MARK: - Editors Implementations

    private func listEditor(blockID: UUID, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                HStack {
                    TextField("Item \(i+1)", text: Binding(
                        get: { itemsAt(blockID)[i] },
                        set: { updateListItem(blockID: blockID, index: i, text: $0) }
                    ))
                    Button(role: .destructive) {
                        removeListItem(blockID: blockID, index: i)
                    } label: { Image(systemName: "minus.circle") }
                }
            }
            Button {
                addListItem(blockID: blockID)
            } label: {
                Label("Add item", systemImage: "plus.circle")
            }
        }
    }

    private func checklistEditor(blockID: UUID, entries: [ChecklistEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entries.indices, id: \.self) { i in
                HStack {
                    Toggle("", isOn: Binding(
                        get: { checklistAt(blockID)[i].isDone },
                        set: { updateChecklistDone(blockID: blockID, index: i, isOn: $0) }
                    ))
                    TextField("Text", text: Binding(
                        get: { checklistAt(blockID)[i].text },
                        set: { updateChecklistText(blockID: blockID, index: i, text: $0) }
                    ))
                    Button(role: .destructive) {
                        removeChecklistItem(blockID: blockID, index: i)
                    } label: { Image(systemName: "minus.circle") }
                }
            }
            Button {
                addChecklistItem(blockID: blockID)
            } label: {
                Label("Add checklist item", systemImage: "plus.circle")
            }
        }
    }

    private func faqEditor(blockID: UUID, q: String, a: String) -> some View {
        VStack(spacing: 8) {
            TextField("Question", text: Binding(
                get: { faqAt(blockID).0 },
                set: { updateFAQ(blockID: blockID, question: $0, answer: faqAt(blockID).1) }
            ))
            TextField("Answer", text: Binding(
                get: { faqAt(blockID).1 },
                set: { updateFAQ(blockID: blockID, question: faqAt(blockID).0, answer: $0) }
            ))
        }
    }

    private func linksEditor(blockID: UUID, links: [LinkEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(links.indices, id: \.self) { i in
                VStack(spacing: 6) {
                    TextField("Title", text: Binding(
                        get: { linksAt(blockID)[i].title },
                        set: { updateLinkTitle(blockID: blockID, index: i, title: $0) }
                    ))
                    TextField("Article ID", text: Binding(
                        get: { linksAt(blockID)[i].articleId },
                        set: { updateLinkArticleId(blockID: blockID, index: i, articleId: $0) }
                    ))
                }
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        removeLink(blockID: blockID, index: i)
                    } label: { Image(systemName: "minus.circle") }
                }
            }
            Button {
                addLink(blockID: blockID)
            } label: {
                Label("Add link", systemImage: "plus.circle")
            }
        }
    }

    // MARK: - Bindings & Mutations (helpers)

    private func bindingContent(for id: UUID, original: String) -> Binding<String> {
        Binding(
            get: {
                if case .content(let t) = blockBy(id)?.payload { return t }
                return original
            },
            set: { newValue in
                guard let idx = viewModel.blocks.firstIndex(where: { $0.id == id }) else { return }
                viewModel.blocks[idx].payload = .content(newValue)
            }
        )
    }

    private func blockBy(_ id: UUID) -> ArticleBlock? {
        viewModel.blocks.first(where: { $0.id == id })
    }

    // list
    private func itemsAt(_ id: UUID) -> [String] {
        if case .list(let items) = blockBy(id)?.payload { return items }
        return []
    }
    private func updateListItem(blockID: UUID, index: Int, text: String) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .list(var items) = viewModel.blocks[idx].payload, items.indices.contains(index) {
            items[index] = text
            viewModel.blocks[idx].payload = .list(items)
        }
    }
    private func addListItem(blockID: UUID) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .list(var items) = viewModel.blocks[idx].payload {
            items.append("")
            viewModel.blocks[idx].payload = .list(items)
        }
    }
    private func removeListItem(blockID: UUID, index: Int) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .list(var items) = viewModel.blocks[idx].payload, items.indices.contains(index) {
            items.remove(at: index)
            viewModel.blocks[idx].payload = .list(items)
        }
    }

    // checklist
    private func checklistAt(_ id: UUID) -> [ChecklistEntry] {
        if case .checklist(let entries) = blockBy(id)?.payload { return entries }
        return []
    }
    private func updateChecklistText(blockID: UUID, index: Int, text: String) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .checklist(var entries) = viewModel.blocks[idx].payload, entries.indices.contains(index) {
            entries[index].text = text
            viewModel.blocks[idx].payload = .checklist(entries)
        }
    }
    private func updateChecklistDone(blockID: UUID, index: Int, isOn: Bool) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .checklist(var entries) = viewModel.blocks[idx].payload, entries.indices.contains(index) {
            entries[index].isDone = isOn
            viewModel.blocks[idx].payload = .checklist(entries)
        }
    }
    private func addChecklistItem(blockID: UUID) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .checklist(var entries) = viewModel.blocks[idx].payload {
            entries.append(ChecklistEntry())
            viewModel.blocks[idx].payload = .checklist(entries)
        }
    }
    private func removeChecklistItem(blockID: UUID, index: Int) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .checklist(var entries) = viewModel.blocks[idx].payload, entries.indices.contains(index) {
            entries.remove(at: index)
            viewModel.blocks[idx].payload = .checklist(entries)
        }
    }

    // faq
    private func faqAt(_ id: UUID) -> (String, String) {
        if case .faq(let q, let a) = blockBy(id)?.payload { return (q, a) }
        return ("", "")
    }
    private func updateFAQ(blockID: UUID, question: String, answer: String) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        viewModel.blocks[idx].payload = .faq(question: question, answer: answer)
    }

    // links
    private func linksAt(_ id: UUID) -> [LinkEntry] {
        if case .links(let ls) = blockBy(id)?.payload { return ls }
        return []
    }
    private func updateLinkTitle(blockID: UUID, index: Int, title: String) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .links(var ls) = viewModel.blocks[idx].payload, ls.indices.contains(index) {
            ls[index].title = title
            viewModel.blocks[idx].payload = .links(ls)
        }
    }
    private func updateLinkArticleId(blockID: UUID, index: Int, articleId: String) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .links(var ls) = viewModel.blocks[idx].payload, ls.indices.contains(index) {
            ls[index].articleId = articleId
            viewModel.blocks[idx].payload = .links(ls)
        }
    }
    private func addLink(blockID: UUID) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .links(var ls) = viewModel.blocks[idx].payload {
            ls.append(LinkEntry())
            viewModel.blocks[idx].payload = .links(ls)
        }
    }
    private func removeLink(blockID: UUID, index: Int) {
        guard let idx = viewModel.blocks.firstIndex(where: { $0.id == blockID }) else { return }
        if case .links(var ls) = viewModel.blocks[idx].payload, ls.indices.contains(index) {
            ls.remove(at: index)
            viewModel.blocks[idx].payload = .links(ls)
        }
    }
}
