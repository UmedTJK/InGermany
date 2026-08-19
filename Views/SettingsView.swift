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
            List {
                // MARK: - App Header
                Section {
                    HStack(spacing: DS.Spacing.m) {
                        Image("LogoLight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("app.name")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("settings.app_version")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, DS.Spacing.xs)
                    .listRowBackground(Color.clear)
                }

                // MARK: - Language
                Section {
                    Picker(
                        "settings.language.picker",
                        selection: Binding<String>(
                            get: { localizationSettings.language },
                            set: { localizationSettings.setLanguage($0) }
                        )
                    ) {
                        Label("🇷🇺 Русский", systemImage: "globe").tag("ru")
                        Label("🇬🇧 English", systemImage: "globe").tag("en")
                        Label("🇹🇯 Тоҷикӣ", systemImage: "globe").tag("tg")
                    }
                    .pickerStyle(.menu)
                    .listRowBackground(DS.Color.secondarySurface.opacity(0.5))
                } header: {
                    Label("settings.language.section", systemImage: "globe")
                }

                // MARK: - Appearance
                Section {
                    Toggle(isOn: $viewModel.isDarkMode) {
                        HStack(spacing: DS.Spacing.m) {
                            Image(systemName: viewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundStyle(viewModel.isDarkMode ? .yellow : .orange)
                                .frame(width: 24)
                            Text("settings.appearance.dark_mode")
                        }
                    }
                    .accessibilityLabel(Text("settings.appearance.dark_mode.a11y"))
                    .listRowBackground(DS.Color.secondarySurface.opacity(0.5))
                } header: {
                    Label("settings.appearance.section", systemImage: "paintbrush")
                }

                // MARK: - Date Format
                Section {
                    Toggle(isOn: $viewModel.relativeDates) {
                        HStack(spacing: DS.Spacing.m) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text("settings.date_format.relative_dates")
                        }
                    }
                    .accessibilityLabel(Text("settings.date_format.relative_dates.a11y"))
                    .listRowBackground(DS.Color.secondarySurface.opacity(0.5))
                } header: {
                    Label("settings.date_format.section", systemImage: "calendar")
                }

                // MARK: - Statistics
                Section {
                    HStack(spacing: DS.Spacing.m) {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(.purple)
                            .frame(width: 24)
                        Text("settings.statistics.disabled")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(DS.Color.secondarySurface.opacity(0.5))
                } header: {
                    Label("settings.statistics.section", systemImage: "chart.bar")
                }

                // MARK: - About
                Section {
                    NavigationLink(destination: AboutView(viewModel: makeAboutViewModel())) {
                        HStack(spacing: DS.Spacing.m) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            Text("tab.about")
                        }
                    }
                    .listRowBackground(DS.Color.secondarySurface.opacity(0.5))
                } header: {
                    Label("settings.about.section", systemImage: "info.circle")
                }

                // MARK: - Footer
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Made with ❤️ in Germany")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("© 2026 InGermany")
                                .font(.caption2)
                                .foregroundStyle(.secondary.opacity(0.6))
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(DS.Color.background)
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if viewModel.isHistoryCleared {
                    HistoryClearedToast(
                        message: String(localized: "settings.history.cleared")
                    )
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: viewModel.isHistoryCleared)
        }
    }
}

// MARK: - HistoryClearedToast
private struct HistoryClearedToast: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: DS.Spacing.s) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(DS.Spacing.m)
            .padding(.horizontal, DS.Spacing.l)
            .cardContainer(.standard(useMaterial: true))
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.m)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: true)
    }
}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    SettingsView(
        viewModel: container.makeSettingsViewModel(),
        makeAboutViewModel: container.makeAboutViewModel,
        dumpNetworkMetrics: { _ in "Mock" }
    )
    .environmentObject(container.localizationManager)
}
