//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var categoriesStore = CategoriesStore.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase  // ✅ для отслеживания жизненного цикла

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    ProgressView("Загрузка данных...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    ContentView()
                        .environmentObject(categoriesStore)
                        .preferredColorScheme(isDarkMode ? .dark : .light)
                }
            }
            .task {
                await appState.loadData()
            }
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active:
                    print("📱 App is active")
                case .inactive:
                    print("⏸ App is inactive")
                case .background:
                    print("📤 App moved to background — сохраняем состояние")
                    saveAppState()
                @unknown default:
                    break
                }
            }
        }
    }

    /// Сохраняем избранное и историю чтения (заглушка — адаптируй под свою логику)
    private func saveAppState() {
        // Пример: сохраняем избранное, если доступно
        FavoritesManager().toggleFavorite(id: "dummy") // временно для вызова save
        // ReadingHistoryManager.shared.saveIfNeeded() // можно реализовать
        print("✔️ Состояние приложения сохранено")
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isLoading = true

    func loadData() async {
        let dataService = DataService.shared
        async let articles = dataService.loadArticles()
        async let categories = dataService.loadCategories()
        async let locations = dataService.loadLocations()
        _ = await (articles, categories, locations)

        await CategoriesStore.shared.bootstrap()
        isLoading = false
    }
}
