//
//  TextSizeSettingsPanel.swift
//  InGermany
//

import SwiftUI

struct TextSizeSettingsPanel: View {
    @ObservedObject private var textSizeManager = TextSizeManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Пример текста
                Text(t("Пример текста"))
                    .font(.system(size: 17 * textSizeManager.customScale))
                    .padding()

                // Ползунок
                VStack(spacing: 8) {
                    HStack {
                        Text("A")
                            .font(.system(size: 14))
                        Slider(value: $textSizeManager.customScale, in: 0.8...1.5, step: 0.05)
                        Text("A")
                            .font(.system(size: 24))
                    }
                    .padding(.horizontal)

                    Text("\(Int(textSizeManager.customScale * 100))%")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                // Сброс
                HStack {
                    Button(action: {
                        textSizeManager.setTextSize(.medium)
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

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
