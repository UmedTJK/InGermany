import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appContainer = AppContainer.shared
    @StateObject private var appState = AppState(appContainer: AppContainer.shared) // ← ИСПРАВЛЕНО: инжектим контейнер
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
                        // ✅ ПЕРЕДАЕМ ВСЕ НЕОБХОДИМЫЕ ENVIRONMENT OBJECTS
                        .environmentObject(appContainer)
                        .environmentObject(appContainer.favoritesManager)
                        .environmentObject(appContainer.textSizeManager)
                        .environmentObject(appContainer.localizationManager)
                        .environmentObject(appContainer.readingProgressTracker)
                        .preferredColorScheme(isDarkMode ? .light : .dark)
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
    private let appContainer: AppContainer // ← ДОБАВЛЕНО: зависимость через DI

    init(appContainer: AppContainer) { // ← ИСПРАВЛЕНО: инжектим контейнер
        self.appContainer = appContainer
    }

    func loadData() async {
        // ✅ ИСПОЛЬЗУЕМ ЗАВИСИМОСТИ ИЗ КОНТЕЙНЕРА ВМЕСТО ПРЯМЫХ SINGLETONS
        async let articles = appContainer.dataService.loadArticles()
        async let categories = appContainer.dataService.loadCategories()
        async let locations = appContainer.dataService.loadLocations()
        _ = await (articles, categories, locations)

        // ✅ ИСПОЛЬЗУЕМ КОНТЕЙНЕР ДЛЯ РЕПОЗИТОРИЕВ
        await appContainer.categoriesRepo.bootstrap()
        isLoading = false
    }
}
