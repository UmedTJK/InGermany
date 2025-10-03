//
//  AboutViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
//
//  AboutViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class AboutViewModel: ObservableObject {
    @Published var appVersion: String
    @Published var buildNumber: String
    @Published var repositoryURL: String = "https://github.com/UmedTJK/InGermany"

    init() {
        let info = Bundle.main.infoDictionary
        self.appVersion = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        self.buildNumber = info?["CFBundleVersion"] as? String ?? "1"
    }
}
