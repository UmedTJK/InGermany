//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var appContainer = AppContainer() // ⬅️ убрали .shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                // ✅ Передаём зависимости
                .environmentObject(appContainer)
                .environmentObject(appContainer.favoritesManager)
                .environmentObject(appContainer.textSizeManager)
                .environmentObject(appContainer.localizationManager)
                .environmentObject(appContainer.ratingManager)
                .environmentObject(appContainer.readingStatsManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.screenSize, UIScreen.main.bounds.size)
                .task {
                    // 🔹 Асинхронный preload — UI не блокируется
                    await appContainer.bootstrap()
                }
        }
    }
}
