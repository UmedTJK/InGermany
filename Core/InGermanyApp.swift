//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appContainer = AppContainer.shared
    @StateObject private var appState = AppState(appContainer: AppContainer.shared)
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    ProgressView("Загрузка данных...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    ContentView()
                        // ✅ Передаём зависимости
                        .environmentObject(appContainer)
                        .environmentObject(appContainer.favoritesManager)
                        .environmentObject(appContainer.textSizeManager)
                        .environmentObject(appContainer.localizationManager)
                        .environmentObject(appContainer.ratingManager)
                        .environmentObject(appContainer.readingStatsManager) // 👈 конкретный ObservableObject
                        .preferredColorScheme(isDarkMode ? .light : .dark)
                        .environment(\.screenSize, UIScreen.main.bounds.size)
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
    private let appContainer: AppContainer

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    func loadData() async {
        async let articles = appContainer.dataService.loadArticles()
        async let categories = appContainer.dataService.loadCategories()
        async let locations = appContainer.dataService.loadLocations()
        _ = await (articles, categories, locations)

        await appContainer.categoriesRepo.bootstrap()
        isLoading = false
    }
}
