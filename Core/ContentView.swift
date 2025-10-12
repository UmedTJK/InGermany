//
//  ContentView.swift
//  InGermany
//

import SwiftUI

/// Обёртка для ленивой инициализации во вкладках
struct LazyView<Content: View>: View {
    private let build: () -> Content
    init(_ build: @escaping () -> Content) { self.build = build }
    var body: some View { build() }
}

struct ContentView: View {
    @EnvironmentObject var appContainer: AppContainer
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var readingStatsManager: ReadingStatsManager
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        CustomTabBarView(appContainer: appContainer)
            // 🔹 Глобальное управление темой
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .onAppear {
                // 🔹 Стартуем неблокирующий preload
                appContainer.bootstrap()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.previewMock())
        .environmentObject(LocalizationManager.shared)
        .environmentObject(FavoritesManager.shared)
        .environmentObject(ReadingStatsManager.shared)
}
