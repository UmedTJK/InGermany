import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appContainer = AppContainer.shared // ← ИСПРАВЛЕНО: используем AppContainer вместо отдельных репозиториев
    @StateObject private var appState = AppState()
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
                        .environmentObject(appContainer) // ← ИСПРАВЛЕНО: передаем appContainer вместо categoriesRepository
                        .preferredColorScheme(isDarkMode ? .dark : .light)
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

    func loadData() async {
        let dataService = DataService.shared
        async let articles = dataService.loadArticles()
        async let categories = dataService.loadCategories()
        async let locations = dataService.loadLocations()
        _ = await (articles, categories, locations)

        await DefaultCategoriesRepository.shared.bootstrap()
        isLoading = false
    }
}
