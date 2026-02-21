import SwiftUI

@main
struct InGermanyApp: App {

    @StateObject private var settingsManager: SettingsManager
    @StateObject private var appContainer: AppContainer

    init() {
        let sm = SettingsManager()
        _settingsManager = StateObject(wrappedValue: sm)
        _appContainer = StateObject(wrappedValue: AppContainer(settingsManager: sm))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appContainer: appContainer)
                .appEnvironment(using: appContainer)
                .environmentObject(settingsManager)

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
