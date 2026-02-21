//
//  View+AppEnvironment.swift
//  InGermany
//
//  Created by SUM TJK on 20.02.26.
//
import SwiftUI

extension View {
    func appEnvironment(using container: AppContainer) -> some View {
        self
            .environmentObject(container)
            .environmentObject(container.favoritesManagerForUI)
            .environmentObject(container.textSizeManager)
            .environmentObject(container.localizationManager)
            .environmentObject(container.ratingManager)
            .environmentObject(container.readingStatsManagerForUI)
    }
}
