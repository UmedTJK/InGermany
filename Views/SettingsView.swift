//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("textSize") private var textSize: Double = 16
    @AppStorage("useRelativeDates") private var useRelativeDates: Bool = true

    @State private var articlesRead: Int = 42
    @State private var totalReadingTime: Int = 135
    @State private var avgTimePerArticle: Double = 3.2
    @State private var readingStreak: Int = 5

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(t("settings_language_title"))) {
                    LanguagePickerView()
                }

                Section(header: Text(t("settings_appearance_title"))) {
                    Toggle(isOn: $isDarkMode) {
                        Text(t("settings_dark_mode"))
                    }
                    Stepper(value: $textSize, in: 12...24, step: 1) {
                        Text("\(t("settings_text_size")): \(Int(textSize))")
                    }
                }

                Section(header: Text(t("settings_date_format"))) {
                    Toggle(isOn: $useRelativeDates) {
                        Text(t("settings_relative_dates"))
                    }
                }

                Section(header: Text(t("settings_reading_stats"))) {
                    HStack {
                        Text(t("settings_articles_read"))
                        Spacer()
                        Text("\(articlesRead)")
                    }
                    HStack {
                        Text(t("settings_total_time"))
                        Spacer()
                        Text("\(totalReadingTime) \(unitMinutes())")
                    }
                    HStack {
                        Text(t("settings_avg_time"))
                        Spacer()
                        Text(String(format: "%.1f \(unitMinutes())", avgTimePerArticle))
                    }
                    HStack {
                        Text(t("settings_streak"))
                        Spacer()
                        Text("\(readingStreak)")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        clearHistory()
                    } label: {
                        Text(t("settings_clear_history"))
                    }
                }

                Section(header: Text(t("settings_about"))) {
                    Text(t("about_description"))
                    NavigationLink(destination: AboutView()) {
                        Text(t("tab_about"))
                    }
                }
            }
            .navigationTitle(t("Настройки")) // используем ключ из LocalizationManager
        }
    }

    private func clearHistory() {
        articlesRead = 0
        totalReadingTime = 0
        avgTimePerArticle = 0
        readingStreak = 0
    }

    // 🔹 Удобный шорткат для перевода
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }

    // 🔹 Перевод единиц измерения для минут
    private func unitMinutes() -> String {
        switch selectedLanguage {
        case "en": return "min"
        case "de": return "Min."
        case "tj": return "дақ"
        case "fa": return "دقیقه"
        case "ar": return "دقيقة"
        case "uk": return "хв"
        default: return "мин"
        }
    }
}
