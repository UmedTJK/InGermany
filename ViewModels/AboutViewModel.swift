//
//  AboutViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.


import SwiftUI

/// View model that manages app metadata for display in the About screen.
@MainActor
class AboutViewModel: ObservableObject {
    /// The app’s current version string from Info.plist.
    @Published var appVersion: String
    /// The app’s current build number from Info.plist.
    @Published var buildNumber: String
    /// The GitHub repository URL of the project.
    @Published var repositoryURL: String = "https://github.com/UmedTJK/InGermany"

    /// Initializes the view model and loads version and build information from the app bundle.
    init() {
        let info = Bundle.main.infoDictionary
        self.appVersion = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.buildNumber = info?["CFBundleVersion"] as? String ?? "1"
    }
}
