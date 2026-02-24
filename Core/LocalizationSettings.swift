//
//  LocalizationSettings.swift.swift
//  InGermany
//
//  Created by SUM TJK on 24.02.26.
//
import SwiftUI

@MainActor
final class LocalizationSettings: ObservableObject {

    @AppStorage("selectedLanguage") private var storedLanguage: String = "ru"

    @Published private(set) var language: String

    var locale: Locale {
        Locale(identifier: language)
    }

    init() {
        // Avoid accessing @AppStorage before full initialization
        let raw = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "ru"
        let normalized = Self.normalize(raw)
        self.language = normalized
        self.storedLanguage = normalized
    }

    func setLanguage(_ newLanguage: String) {
        guard language != newLanguage else { return }
        language = newLanguage
        storedLanguage = newLanguage
    }

    private static func normalize(_ value: String) -> String {
        let lower = value.lowercased()
        if lower.hasPrefix("ru") { return "ru" }
        if lower.hasPrefix("en") { return "en" }
        if lower.hasPrefix("tg") { return "tg" }
        return "ru"
    }
}
