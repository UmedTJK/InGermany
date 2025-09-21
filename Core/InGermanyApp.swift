//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var categoriesStore = CategoriesStore.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    ProgressView("Загрузка данных...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    ContentView(
                        articles: appState.articles,
                        categories: appState.categories
                    )
                    .environmentObject(categoriesStore)
                }
            }
            .task {
                await appState.loadData()
            }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isLoading = true
    @Published var articles: [Article] = []
    @Published var categories: [Category] = []

    func loadData() async {
        let dataService = DataService.shared
        async let articlesTask = dataService.loadArticles()
        async let categoriesTask = dataService.loadCategories()
        async let locationsTask = dataService.loadLocations()

        let (articles, categories, _) = await (articlesTask, categoriesTask, locationsTask)

        self.articles = articles
        self.categories = categories

        await CategoriesStore.shared.bootstrap()
        isLoading = false
    }
}
