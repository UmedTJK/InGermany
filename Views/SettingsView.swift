import SwiftUI

/// The settings screen of the app, allowing the user to configure appearance, language, date format, statistics, and history.
struct SettingsView: View {
    @EnvironmentObject var appContainer: AppContainer

    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    /// Primary initializer for runtime usage - DI through parameters
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    



    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                languageSection
                appearanceSection
                cardStyleSection
                dateFormatSection
                statisticsSection
                aboutSection
                clearHistorySection
                resetSection
            }
            .navigationTitle(viewModel.localizedText("settings_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isHistoryCleared {
                    HistoryClearedToast()
                }
            }
        }
    }

    // MARK: - Section Views
    
    private var languageSection: some View {
        Section {
            LanguagePickerView(selectedLanguage: $viewModel.selectedLanguage)
        } header: {
            Text(viewModel.localizedText("settings_language_section"))
        }
    }
    
    private var appearanceSection: some View {
        Section {
            Toggle(isOn: $viewModel.isDarkMode) {
                Text(viewModel.localizedText("settings_dark_mode"))
                    .accessibilityLabel(viewModel.localizedText("settings_dark_mode_accessibility"))
            }
        } header: {
            Text(viewModel.localizedText("settings_appearance_title"))
        }
    }
    
    private var cardStyleSection: some View {
        Section {
            Picker(viewModel.localizedText("settings_card_style_photo"), selection: $viewModel.cardImageStyle) {
                ForEach(CardImageStyle.allCases) { style in
                    Text(style.localizedTitle)
                        .tag(style)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(viewModel.localizedText("settings_card_style_accessibility"))
        } header: {
            Text(viewModel.localizedText("settings_card_style"))
        }
    }
    
    private var dateFormatSection: some View {
        Section {
            Toggle(isOn: $viewModel.relativeDates) {
                Text(viewModel.localizedText("settings_relative_dates"))
                    .accessibilityLabel(viewModel.localizedText("settings_relative_dates_accessibility"))
            }
        } header: {
            Text(viewModel.localizedText("settings_date_format_title"))
        }
    }
    
    private var statisticsSection: some View {
        Section {
            let stats = viewModel.getStats()
            let avgMinutes = stats.totalArticlesRead > 0
                ? Double(stats.totalReadingTimeMinutes) / Double(stats.totalArticlesRead)
                : 0.0
            
            StatisticRow(
                title: viewModel.localizedText("settings_articles_read"),
                value: "\(stats.totalArticlesRead)"
            )
            
            StatisticRow(
                title: viewModel.localizedText("settings_total_time"),
                value: formatHMS(fromSeconds: stats.totalReadingTimeMinutes * 60)
            )
            
            StatisticRow(
                title: viewModel.localizedText("settings_average_time"),
                value: formatHMS(fromSeconds: Int(avgMinutes * 60))
            )
            
            StatisticRow(
                title: viewModel.localizedText("settings_streak"),
                value: "\(stats.readingStreak)"
            )
        } header: {
            Text(viewModel.localizedText("settings_stats_title"))
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink(destination: AboutView(appContainer: AppContainer.shared)) {
                Text(viewModel.localizedText("settings_about_title"))
            }

        }
    }
    
    private var clearHistorySection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.clearHistory()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text(viewModel.localizedText("settings_clear_history"))
                }
            }
            .accessibilityLabel(viewModel.localizedText("settings_clear_history_accessibility"))
        }
    }
    
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.resetToDefaults()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(viewModel.localizedText("settings_reset_defaults"))
                }
            }
            .accessibilityLabel(viewModel.localizedText("settings_reset_defaults_accessibility"))
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatHMS(fromSeconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let mins = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%d:%02d", mins, secs)
        }
    }
}

// MARK: - Supporting Views

private struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }
}

private struct HistoryClearedToast: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("История очищена")
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(), value: true)
    }
}

// MARK: - Preview
#Preview("Default Settings") {
    SettingsView(viewModel: .previewMock())
        .environmentObject(AppContainer.previewMock())
}

#Preview("With Stats") {
    SettingsView(viewModel: .previewMockWithStats())
        .environmentObject(AppContainer.previewMock())
}
