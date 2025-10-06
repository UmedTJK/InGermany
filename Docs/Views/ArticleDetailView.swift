//
//  ArticleDetailView.swift
//  InGermany
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let allArticles: [Article]
    @StateObject private var viewModel: ArticleDetailViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru" // ← ДОБАВИТЬ ЭТО

    init(article: Article, allArticles: [Article]) {
        self.article = article
        self.allArticles = allArticles
        _viewModel = StateObject(wrappedValue: ArticleDetailViewModel(
            article: article,
            allArticles: allArticles,
            favoritesManager: FavoritesManager.shared,
            historyManager: ReadingHistoryManager.shared // ← ИСПРАВЛЕНО ИМЯ ПАРАМЕТРА
        ))
    }

    var body: some View {
        // Упрощенная версия без прямых зависимостей от менеджеров
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.article.localizedTitle(for: selectedLanguage))
                    .font(.title)
                    .bold()
                
                // Контент статьи...
                Text(viewModel.article.localizedContent(for: selectedLanguage))
                    .font(.body)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markAsRead()
        }
    }
}

// УДАЛИТЬ этот дублирующий инициализатор - он уже есть выше!
// init(article: Article, allArticles: [Article]) {
//     self.article = article
//     self.allArticles = allArticles
//     _viewModel = StateObject(wrappedValue: ArticleDetailViewModel(
//         article: article,
//         allArticles: allArticles,
//         favoritesManager: FavoritesManager.shared,
//         readingHistoryManager: ReadingHistoryManager.shared
//     ))
// }

#Preview {
    ArticleDetailView(
        article: Article.sampleArticles[0],
        allArticles: Article.sampleArticles
    )
}
