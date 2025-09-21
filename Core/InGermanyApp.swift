//
//  InGermanyApp.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
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
                    ContentView()
                        .environmentObject(categoriesStore)
                }
            }
            .task {
                await appState.loadData() // загрузка через AppState
            }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isLoading = true

    func loadData() async {
        // Предзагрузка данных через DataService
        let dataService = DataService.shared
        async let articles = dataService.loadArticles()
        async let categories = dataService.loadCategories()
        async let locations = dataService.loadLocations()
        _ = await (articles, categories, locations)

        // Мост для вью: поднять CategoriesStore
        await CategoriesStore.shared.bootstrap()

        // Готово
        isLoading = false
    }
}
