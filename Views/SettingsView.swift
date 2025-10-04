//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

/// The settings screen of the app, allowing the user to configure appearance, language, date format, statistics, and history.
struct SettingsView: View {
    /// Stores whether dark mode is enabled.
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    /// Stores the preferred card image style.
    @AppStorage("cardImageStyle") private var cardImageStyle: CardImageStyle = .bottomCorners
    /// Stores whether dates should be shown in relative format.
    @AppStorage("relativeDates") private var relativeDates: Bool = true

    /// ViewModel providing reading statistics and history management.
    @StateObject private var viewModel: SettingsViewModel

    /// Initializes the settings view with a provided or default SettingsViewModel.
    init(viewModel: SettingsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AppContainer.shared.makeSettingsViewModel())
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
                    NavigationLink(destination: AboutView()) {
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
    }
