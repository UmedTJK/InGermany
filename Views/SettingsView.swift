//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("cardImageStyle") private var cardImageStyle: CardImageStyle = .bottomCorners
    @AppStorage("relativeDates") private var relativeDates: Bool = true
    
    @ObservedObject private var historyManager = ReadingHistoryManager.shared
    
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
                Section(header: Text(t("settings_stats_title"))) {
                    let stats = historyManager.getStats()
                    
                    HStack {
                        Text(t("settings_articles_read"))
                        Spacer()
                        Text("\(stats.totalArticlesRead)")
                    }
                    HStack {
                        Text(t("settings_total_time"))
                        Spacer()
                        Text(formatHMS(fromSeconds: stats.totalReadingTimeSeconds))
                    }
                    HStack {
                        Text(t("settings_average_time"))
                        Spacer()
                        let avgSeconds = stats.totalArticlesRead > 0
                            ? Double(stats.totalReadingTimeSeconds) / Double(stats.totalArticlesRead)
                            : 0.0
                        Text(formatHMS(fromSeconds: Int(avgSeconds)))
                    }
                    HStack {
                        Text(t("settings_streak"))
                        Spacer()
                        Text("\(stats.readingStreak)")
                    }
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
                        historyManager.clearHistory()
                    } label: {
                        Text(t("settings_clear_history"))
                    }
                }
            }
            .navigationTitle(t("settings_title"))
        }
    }
    
    /// Форматирование времени чтения в ЧЧ:ММ:СС (или ММ:СС, если меньше часа)
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
