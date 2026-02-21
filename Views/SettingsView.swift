//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appContainer: AppContainer
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Init
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                languageSection
                appearanceSection
                dateFormatSection
                Section(header: Text(viewModel.localizedText("settings_stats_title"))) {
                    Text("Статистика чтения временно отключена")
                }
                aboutSection
                clearHistorySection
                resetSection
            }
            .navigationTitle(viewModel.localizedText("settings_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.localizedText("settings_done")) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isHistoryCleared {
                    HistoryClearedToast(
                        message: viewModel.localizedText("settings_history_cleared")
                    )
                }
            }
        }
    }

    // MARK: - Sections
    private var languageSection: some View {
        Section(header: Text(viewModel.localizedText("settings_language_section"))) {
            Picker(viewModel.localizedText("settings_language_picker"), selection: $viewModel.selectedLanguage) {
                ForEach(viewModel.supportedLanguages, id: \.self) { code in
                    Text(viewModel.displayName(for: code)).tag(code)
                }
            }
        }
    }

    private var appearanceSection: some View {
        Section(header: Text(viewModel.localizedText("settings_appearance_title"))) {
            Toggle(isOn: $viewModel.isDarkMode) {
                Text(viewModel.localizedText("settings_dark_mode"))
            }
            .accessibilityLabel(viewModel.localizedText("settings_dark_mode_accessibility"))
        }
    }

    private var cardStyleSection: some View {
        Section(header: Text(viewModel.localizedText("settings_card_style_title"))) {
            Picker(viewModel.localizedText("settings_card_style_picker"), selection: Binding<CardImageStyle>(
                get: { viewModel.selectedCardStyle },
                set: { viewModel.selectedCardStyle = $0 }
            )) {
                ForEach(Array(CardImageStyle.allCases), id: \.self) { style in
                    Text(style.title).tag(style)
                }
            }
        }
    }

    private var dateFormatSection: some View {
        Section(header: Text(viewModel.localizedText("settings_date_format_title"))) {
            Toggle(isOn: $viewModel.relativeDates) {
                Text(viewModel.localizedText("settings_relative_dates"))
            }
            .accessibilityLabel(viewModel.localizedText("settings_relative_dates_accessibility"))
        }
    }

    private var aboutSection: some View {
        Section(header: Text(viewModel.localizedText("settings_about_title"))) {
            NavigationLink(destination: AboutView(viewModel: appContainer.makeAboutViewModel())) {
                Text(viewModel.localizedText("tab_about"))
            }
        }
    }


    private var clearHistorySection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.clearHistory()
            } label: {
                Text(viewModel.localizedText("settings_clear_history"))
            }
            .accessibilityLabel(viewModel.localizedText("settings_clear_history_accessibility"))
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.resetToDefaults()
            } label: {
                Text(viewModel.localizedText("settings_reset_defaults"))
            }
            .accessibilityLabel(viewModel.localizedText("settings_reset_defaults_accessibility"))
        }
    }
}

// MARK: - HistoryClearedToast
private struct HistoryClearedToast: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(message)
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
