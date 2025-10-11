//
//  TextSizeSettingsPanel.swift
//  InGermany
//

import SwiftUI

/// Панель для изменения размера текста
struct TextSizeSettingsPanel: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    /// Контейнер зависимостей для получения менеджеров.
    @EnvironmentObject private var appContainer: AppContainer

    /// Строит пользовательский интерфейс для настройки размера текста с предварительным просмотром, ползунком, сбросом и кнопкой подтверждения
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Пример текста
                Text(t("Пример текста"))
                    .font(.system(size: 17 * appContainer.textSizeManager.customScale))
                    .padding()

                // Ползунок
                VStack(spacing: 8) {
                    HStack {
                        Text("A")
                            .font(.system(size: 14))
                        Slider(
                            value: Binding(
                                get: { appContainer.textSizeManager.customScale },
                                set: { appContainer.textSizeManager.customScale = $0 }
                            ),
                            in: 0.8...1.5,
                            step: 0.05
                        )
                        Text("A")
                            .font(.system(size: 24))
                    }
                    .padding(.horizontal)

                    Text("\(Int(appContainer.textSizeManager.customScale * 100))%")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // Сброс
                HStack {
                    Button(action: {
                        appContainer.textSizeManager.setTextSize(.medium)
                    }) {
                        Text(t("Сбросить"))
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(t("Настройки текста"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("Готово")) {
                        // закрытие панели
                    }
                }
            }
        }
    }

    /// Обрабатывает локализованный поиск перевода для строк пользовательского интерфейса
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    TextSizeSettingsPanel()
        .environmentObject(AppContainer.previewMock())
}
