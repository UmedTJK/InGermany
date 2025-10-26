//
//  InGermanyCMSApp.swift
//  InGermanyCMS
//
//  Created by SUM TJK on 17.10.25.
//

import SwiftUI
import ArticleKit

@main
struct InGermanyCMSApp: App {
    @StateObject private var appTheme = AppThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appTheme) // только внедряем
        }
    }
}

