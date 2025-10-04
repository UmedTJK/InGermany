//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

/// Главная точка входа в приложение InGermany.
/// Управляет инициализацией состояния, загрузкой данных и настройкой окружения.
@main
struct InGermanyApp: App {
    /// Глобальное состояние приложения (флаг загрузки и т.п.).
    @StateObject private var appState = AppState()
    /// Репозиторий категорий, предоставляемый через Environment.
    @StateObject private var categoriesRepository = DefaultCategoriesRepository.shared // ← ИСПРАВЛЕНО
    /// Настройка режима отображения (тёмная/светлая тема), сохраняемая в UserDefaults.
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    /// Отслеживание жизненного цикла приложения (активно/фоновый режим).
    @Environment(\.scenePhase) private var scenePhase

    /// Основная сцена приложения.
    /// Содержит ContentView или индикатор загрузки в зависимости от состояния.
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

    /// Сохраняет состояние приложения при переходе в фон.
    private func saveAppState() {
        // FavoritesManager теперь автоматически сохраняется
        print("✔️ Состояние приложения сохранено")
    }
}

/// Класс состояния приложения: управляет процессом загрузки данных.
@MainActor
final class AppState: ObservableObject {
    @Published var isLoading = true

    /// Асинхронная загрузка статей, категорий и локаций, а также проверка ресурсов.
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

        await DefaultCategoriesRepository.shared.bootstrap()
        isLoading = false
    }
}
