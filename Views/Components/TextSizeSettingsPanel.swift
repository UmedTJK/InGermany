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
                Text(t("Пример текста"))
                    .font(textSizeManager.currentFont)
                    .padding()
                
                Slider(
                    value: $textSizeManager.fontSize,
                    in: 12...30,
                    step: 1
                )
                .padding(.horizontal)
                
                HStack {
                    Button(action: {
                        textSizeManager.resetToDefault()
                    }) {
                        Text(t("Сбросить"))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        textSizeManager.isCustomTextSizeEnabled = true
                    }) {
                        Text(t("Пользовательский размер"))
                    }
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
    
    // 🔹 Шорткат для нового менеджера
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
