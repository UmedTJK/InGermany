//
//  InGermanyCMSApp.swift
//  InGermanyCMS
//
//  Created by SUM TJK on 17.10.25.
//

// InGermanyCMSApp.swift
import SwiftUI
import ArticleKit

@main
struct InGermanyCMSApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                ArticleLibraryView(
                    viewModel: ArticleLibraryViewModel(),
                    onOpen: { url in
                        print("Open article at: \(url)")
                        // Здесь будет логика открытия статьи для редактирования
                    }
                )
            } detail: {
                Text("Выберите статью для редактирования")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
