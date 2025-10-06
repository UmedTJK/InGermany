//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

/// The settings screen of the app, allowing the user to configure appearance, language, date format, statistics, and history.
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("cardImageStyle") private var cardImageStyle: CardImageStyle = .bottomCorners
    @AppStorage("relativeDates") private var relativeDates: Bool = true
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var appContainer: AppContainer

    /// Initializes the view with AppContainer for dependency injection
    init(appContainer: AppContainer) {
        _viewModel = StateObject(wrappedValue: appContainer.makeSettingsViewModel())
    }
    
    /// For preview and testing
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// Builds the settings screen UI with sections for language, appearance, card style, date format, statistics, about info, and history clearing.
    var body: some View {
        NavigationView {
            Form {
                // 🔤 Язык
                Section {
                    LanguagePickerView()
                }
                
                // 🎨 Внешний вид
                Section(header: Text(t("settings_appearance_title"))) {
                    Toggle(isOn: $isDarkMode) {
                        Text(t("settings_dark_mode"))
                    }
                }
                
                // 🖼 Стиль карточек
                Section(header: Text(t("settings_card_style"))) {
                    Picker(t("settings_card_style_photo"), selection: $cardImageStyle) {
                        ForEach(CardImageStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 📅 Формат дат
                Section(header: Text(t("settings_date_format_title"))) {
                    Toggle(isOn: $relativeDates) {
                        Text(t("settings_relative_dates"))
                    }
                }
                
                // 📊 Статистика чтения
                Section {
                    let stats = viewModel.getStats()
                    let avgMinutes = stats.totalArticlesRead > 0
                        ? Double(stats.totalReadingTimeMinutes) / Double(stats.totalArticlesRead)
                        : 0.0
                    
                    HStack {
                        Text(t("settings_articles_read"))
                        Spacer()
                        Text("\(stats.totalArticlesRead)")
                    }
                    HStack {
                        Text(t("settings_total_time"))
                        Spacer()
                        Text(formatHMS(fromSeconds: stats.totalReadingTimeMinutes * 60))
                    }
                    HStack {
                        Text(t("settings_average_time"))
                        Spacer()
                        Text(formatHMS(fromSeconds: Int(avgMinutes * 60)))
                    }
                    HStack {
                        Text(t("settings_streak"))
                        Spacer()
                        Text("\(stats.readingStreak)")
                    }
                } header: {
                    Text(t("settings_stats_title"))
                }
                
                // ℹ️ О приложении
                Section {
                    NavigationLink(destination: AboutView(appContainer: appContainer)) {
                        Text(t("settings_about_title"))
                    }
                }
                
                // 🧹 Очистка истории
                Section {
                    Button(role: .destructive) {
                        viewModel.clearHistory()
                    } label: {
                        Text(t("settings_clear_history"))
                    }
                }
            }
            .navigationTitle(t("settings_title"))
        }
    }
    
    /// Formats total seconds into HH:MM:SS or MM:SS depending on duration.
    private func formatHMS(fromSeconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let mins = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }

    /// Retrieves a localized string for a given key.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    SettingsView(appContainer: AppContainer.shared)
        .environmentObject(AppContainer.shared)
}
