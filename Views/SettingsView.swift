//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var localizationSettings: LocalizationSettings
    private let makeAboutViewModel: () -> AboutViewModel

    private let dumpNetworkMetrics: (_ reset: Bool) async -> String

    // MARK: - Init
    init(
        viewModel: SettingsViewModel,
        makeAboutViewModel: @escaping () -> AboutViewModel,
        dumpNetworkMetrics: @escaping (_ reset: Bool) async -> String = { _ in
            "Network metrics are not wired"
        }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeAboutViewModel = makeAboutViewModel
        self.dumpNetworkMetrics = dumpNetworkMetrics
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                languageSection
                appearanceSection
                dateFormatSection
                Section(header: Text("settings.statistics.section")) {
                    Text("settings.statistics.disabled")
                }
                aboutSection
                clearHistorySection
                resetSection
            }
            .navigationTitle("settings.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done") {
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Color.background)
            .overlay {
                if viewModel.isHistoryCleared {
                    HistoryClearedToast(
                        message: String(localized: "settings.history.cleared")
                    )
                }
            }
            .animation(reduceMotion ? nil : .spring(), value: viewModel.isHistoryCleared)
        }
    }

    // MARK: - Sections
    private var languageSection: some View {
        Section(header: Text("settings.language.section")) {
            Picker(
                "settings.language.picker",
                selection: Binding<String>(
                    get: { localizationSettings.language },
                    set: { localizationSettings.setLanguage($0) }
                )
            ) {
                Text("language.ru").tag("ru")
                Text("language.en").tag("en")
                Text("language.tg").tag("tg")
            }
        }
    }

    private var appearanceSection: some View {
        Section(header: Text("settings.appearance.section")) {
            Toggle(isOn: $viewModel.isDarkMode) {
                Text("settings.appearance.dark_mode")
            }
            .accessibilityLabel(Text("settings.appearance.dark_mode.a11y"))
        }
    }


    private var dateFormatSection: some View {
        Section(header: Text("settings.date_format.section")) {
            Toggle(isOn: $viewModel.relativeDates) {
                Text("settings.date_format.relative_dates")
            }
            .accessibilityLabel(Text("settings.date_format.relative_dates.a11y"))
        }
    }

    private var aboutSection: some View {
        Section(header: Text("settings.about.section")) {
            NavigationLink(destination: AboutView(viewModel: makeAboutViewModel())) {
                Text("tab.about")
            }
        }
    }


    private var clearHistorySection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.clearHistory()
            } label: {
                Text("settings.clear_history")
            }
            .accessibilityLabel(Text("settings.clear_history.a11y"))
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.resetToDefaults()
            } label: {
                Text("settings.reset_defaults")
            }
            .accessibilityLabel(Text("settings.reset_defaults.a11y"))
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
            .padding(DS.Spacing.m)
            .cardContainer(.standard())
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.m)
        }
        .transition(.scale.combined(with: .opacity))
    }
}
