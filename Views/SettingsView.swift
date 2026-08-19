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
            ZStack {
                // Фон
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: DS.Spacing.l) {
                            
                            // Отступ сверху
                            Spacer(minLength: 80)
                                .frame(maxWidth: .infinity)

                            // MARK: - Language
                            settingsCard {
                                VStack(spacing: 0) {
                                    Picker(
                                        "settings.language.picker",
                                        selection: Binding<String>(
                                            get: { localizationSettings.language },
                                            set: { localizationSettings.setLanguage($0) }
                                        )
                                    ) {
                                        Text("🇷🇺 Русский").tag("ru")
                                        Text("🇬🇧 English").tag("en")
                                        Text("🇹🇯 Тоҷикӣ").tag("tg")
                                    }
                                    .pickerStyle(.segmented)
                                    .tint(.blue)
                                    .labelsHidden()
                                }
                            }

                            // MARK: - Appearance
                            settingsCard {
                                Toggle(isOn: $viewModel.isDarkMode) {
                                    HStack(spacing: DS.Spacing.m) {
                                        Image(systemName: viewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                                            .foregroundStyle(viewModel.isDarkMode ? .yellow : .orange)
                                            .frame(width: 24)
                                        Text("settings.appearance.dark_mode")
                                    }
                                }
                                .tint(.blue)
                                .accessibilityLabel(Text("settings.appearance.dark_mode.a11y"))
                            }

                            // MARK: - Date Format
                            settingsCard {
                                Toggle(isOn: $viewModel.relativeDates) {
                                    HStack(spacing: DS.Spacing.m) {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(.blue)
                                            .frame(width: 24)
                                        Text("settings.date_format.relative_dates")
                                    }
                                }
                                .tint(.blue)
                                .accessibilityLabel(Text("settings.date_format.relative_dates.a11y"))
                            }

                            // MARK: - Statistics
                            settingsCard {
                                HStack(spacing: DS.Spacing.m) {
                                    Image(systemName: "chart.bar")
                                        .foregroundStyle(.purple)
                                        .frame(width: 24)
                                    Text("Статистика чтения временно отключена")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            // MARK: - About
                            settingsCard {
                                NavigationLink(destination: AboutView(viewModel: makeAboutViewModel())) {
                                    HStack(spacing: DS.Spacing.m) {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.blue)
                                            .frame(width: 24)
                                        Text("tab.about")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary.opacity(0.5))
                                    }
                                    .contentShape(Rectangle())
                                }
                                .tint(.primary)
                            }
                            
                            // 👇 ДОБАВЛЕННЫЙ ОТСТУП МЕЖДУ ГРУППАМИ
                            Spacer(minLength: DS.Spacing.m)

                            // MARK: - Support
                            settingsCard {
                                VStack(spacing: 0) {
                                    NavigationLink(destination: FAQView()) {
                                        HStack(spacing: DS.Spacing.m) {
                                            Image(systemName: "list.bullet.rectangle.portrait")
                                                .foregroundStyle(.blue)
                                                .frame(width: 24)
                                            Text("Частые вопросы")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary.opacity(0.5))
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .tint(.primary)
                                    .padding(.bottom, DS.Spacing.m)

                                    Divider()
                                        .padding(.vertical, DS.Spacing.s)

                                    Link(destination: URL(string: "mailto:support@ingermany.com?subject=Вопрос%20по%20приложению")!) {
                                        HStack(spacing: DS.Spacing.m) {
                                            Image(systemName: "envelope")
                                                .foregroundStyle(.blue)
                                                .frame(width: 24)
                                            Text("Написать в поддержку")
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.caption)
                                                .foregroundStyle(.secondary.opacity(0.5))
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .tint(.primary)
                                }
                            }

                            // MARK: - Footer
                            VStack(spacing: 4) {
                                Text("Made with ❤️ in Germany")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("© 2026 InGermany")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, DS.Spacing.m)
                            .padding(.bottom, DS.Spacing.l)
                            
                            // Отступ снизу, чтобы не прилипало к TabBar
                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, DS.Spacing.contentInset)
                        .frame(minHeight: geometry.size.height)
                    }
                    .scrollIndicators(.hidden)
                }
                
                // MARK: - Toast
                if viewModel.isHistoryCleared {
                    HistoryClearedToast(
                        message: String(localized: "settings.history.cleared")
                    )
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: viewModel.isHistoryCleared)
        }
    }
    
    // MARK: - Helper Functions
    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(DS.Spacing.m)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
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
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .padding(.horizontal, DS.Spacing.contentInset)
            .padding(.bottom, DS.Spacing.m)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: true)
    }
}

// MARK: - FAQ View (Заглушка)
struct FAQView: View {
    var body: some View {
        List {
            Text("Здесь будет список частых вопросов")
        }
        .navigationTitle("Частые вопросы")
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
