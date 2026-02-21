import SwiftUI

@main
struct InGermanyApp: App {

    @StateObject private var appContainer = AppContainer()
    @StateObject private var settingsManager = SettingsManager()

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
