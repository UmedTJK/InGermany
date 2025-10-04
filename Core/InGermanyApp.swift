//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var categoriesRepository = CategoriesRepository.shared // ← ИСПРАВЛЕНО
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
                        .environmentObject(categoriesRepository) // ← ИСПРАВЛЕНО
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

    private func saveAppState() {
        // FavoritesManager теперь автоматически сохраняется
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

        // 🔎 Проверка ресурсов
        if let resourcePath = Bundle.main.resourcePath {
            let fm = FileManager.default

            if let files = try? fm.contentsOfDirectory(atPath: resourcePath) {
                print("📂 Bundle root contains:")
                files.forEach { print(" - \($0)") }
            }

            let imagesPath = resourcePath + "/Resources/Images"
            if let files = try? fm.contentsOfDirectory(atPath: imagesPath) {
                print("🖼 Images folder contains:")
                files.forEach { print(" - \($0)") }
            }
        }

        await CategoriesRepository.shared.bootstrap()
        isLoading = false
    }
}
