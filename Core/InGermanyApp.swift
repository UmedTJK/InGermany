//
//  InGermanyApp.swift
//  InGermany
//

import SwiftUI

@main
struct InGermanyApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var categoriesStore = CategoriesStore() // Теперь доступен
    @StateObject private var readingHistoryManager = ReadingHistoryManager.shared
    @StateObject private var ratingManager = RatingManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoritesManager)
                .environmentObject(localizationManager)
                .environmentObject(categoriesStore)
                .environmentObject(readingHistoryManager)
                .environmentObject(ratingManager)
        }
    }
}
