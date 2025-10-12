//
//  ArticleRenderer.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

// MARK: - Article Models

struct ArticleSection: Codable, Identifiable {
    var id: String { UUID().uuidString }

    let type: String
    let content: String?
    let items: [ArticleItem]?
    let question: String?
    let answer: String?
}

struct ArticleItem: Codable, Identifiable {
    var id: String { UUID().uuidString }

    let text: String?
    let isDone: Bool?
    let title: String?
    let articleId: String?
}

// MARK: - Article Renderer

struct ArticleRenderer: View {
    let sections: [ArticleSection]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sections) { section in
                    renderSection(section)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func renderSection(_ section: ArticleSection) -> some View {
        switch section.type {
        case "paragraph":
            if let content = section.content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
            }

        case "info":
            if let content = section.content {
                ArticleBlockView(text: content, style: .info)
            }

        case "warning":
            if let content = section.content {
                ArticleBlockView(text: content, style: .warning)
            }

        case "tip":
            if let content = section.content {
                ArticleBlockView(text: content, style: .tip)
            }

        case "quote":
            if let content = section.content {
                ArticleBlockView(text: content, style: .quote)
            }

        case "checklist":
            if let items = section.items {
                ChecklistCardView(items: items.map {
                    ChecklistItem(text: $0.text ?? "", isDone: $0.isDone ?? false)
                })
            }

        case "faq":
            if let question = section.question, let answer = section.answer {
                FAQBlockView(question: question, answer: answer)
            }

        case "links":
            if let items = section.items {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items) { item in
                        if let title = item.title {
                            Text("🔗 \(title)")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    // тут можно сделать переход по articleId
                                    print("Открыть статью: \(item.articleId ?? "")")
                                }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

        default:
            EmptyView()
        }
    }
}

// MARK: - Loader

func loadArticle(named filename: String) -> [ArticleSection] {
    guard let url = Bundle.main.url(forResource: filename,
                                    withExtension: "json",
                                    subdirectory: "articles"),
          let data = try? Data(contentsOf: url),
          let decoded = try? JSONDecoder().decode([ArticleSection].self, from: data)
    else {
        print("⚠️ Не удалось загрузить \(filename).json")
        return []
    }
    return decoded
}


