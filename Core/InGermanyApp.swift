@main
struct InGermanyApp: App {

    @StateObject private var appContainer = AppContainer()
    @StateObject private var settingsManager = SettingsManager()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appContainer)
                .environmentObject(settingsManager)

                // остальные менеджеры — если реально нужны
                .environmentObject(appContainer.localizationManager)
                .environmentObject(appContainer.favoritesManager)
                .environmentObject(appContainer.ratingManager)
                .environmentObject(appContainer.readingStatsManager)

                // 🌙 ЕДИНСТВЕННЫЙ источник темы
                .preferredColorScheme(
                    settingsManager.isDarkMode ? .dark : .light
                )

                .environment(\.screenSize, UIScreen.main.bounds.size)
                .onAppear {
                    appContainer.bootstrap()
                }
        }
    }
}
