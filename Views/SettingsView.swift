//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
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
                cardStyleSection
                dateFormatSection
                Section(header: Text(viewModel.localizedText("settings_stats_title"))) {
                    Text("Статистика чтения временно отключена")
                }
                aboutSection
                clearHistorySection
                resetSection
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle(viewModel.localizedText("settings_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.localizedText("settings_done")) {
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DS.Color.background)
            .overlay {
                if viewModel.isHistoryCleared {
                    HistoryClearedToast(
                        message: viewModel.localizedText("settings_history_cleared")
                    )
                }
            }
            .animation(.spring(), value: viewModel.isHistoryCleared)
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
            NavigationLink(destination: AboutView(viewModel: makeAboutViewModel())) {
                Text(viewModel.localizedText("tab_about"))
            }
            .buttonStyle(.plain)
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

    #if DEBUG
        private var debugSection: some View {
            Section(header: Text("Debug")) {
                NavigationLink("Debug Overlay") {
                    DebugOverlayView(dump: dumpNetworkMetrics)
                }
                .buttonStyle(.plain)

                NavigationLink("Network Metrics") {
                    NetworkMetricsDebugView(dump: dumpNetworkMetrics)
                }
                .buttonStyle(.plain)
            }
        }
    #endif
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
            .background(DS.Color.surface)
            .cornerRadius(DS.Radius.card)
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.m)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

#if DEBUG
private struct DebugOverlayView: View {
    let dump: (_ reset: Bool) async -> String

    @State private var snapshot: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button("Refresh") {
                    Task { await refresh(reset: false) }
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    Task { await refresh(reset: true) }
                } label: {
                    Text("Reset")
                }
                .buttonStyle(.bordered)

                Spacer()
            }

            GroupBox("Snapshot") {
                VStack(alignment: .leading, spacing: 6) {
                    let lines = snapshot.split(separator: "\n").map(String.init)
                    if lines.isEmpty {
                        Text("(empty)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(lines.prefix(12).enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.footnote, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if lines.count > 12 {
                            Text("… (+\(lines.count - 12) more)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Debug Overlay")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await refresh(reset: false)
        }
        .overlay {
            if isLoading { ProgressView() }
        }
    }

    private func refresh(reset: Bool) async {
        isLoading = true
        defer { isLoading = false }
        snapshot = await dump(reset)
    }
}

private struct NetworkMetricsDebugView: View {
    let dump: (_ reset: Bool) async -> String

    @State private var snapshot: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button("Refresh") {
                    Task { await refresh(reset: false) }
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    Task { await refresh(reset: true) }
                } label: {
                    Text("Reset")
                }
                .buttonStyle(.bordered)

                Spacer()
            }

            ScrollView {
                Text(snapshot.isEmpty ? "(empty)" : snapshot)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding()
        .navigationTitle("Network Metrics")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await refresh(reset: false)
        }
        .overlay {
            if isLoading { ProgressView() }
        }
    }

    private func refresh(reset: Bool) async {
        isLoading = true
        defer { isLoading = false }
        snapshot = await dump(reset)
    }
}
#endif
