//
//  TextSizeSettingsPanel.swift
//  InGermany
//

import SwiftUI

struct TextSizeSettingsPanel: View {
    @ObservedObject private var textSizeManager = TextSizeManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var selectedSize: TextSize = .medium // ← ДОБАВЛЕНО: локальное состояние
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(t("Пример текста"))
                    .font(.system(size: getFontSize()))
                    .padding()
                
                Picker(t("Размер текста"), selection: $selectedSize) { // ← ИСПРАВЛЕНО: используем локальное состояние
                    ForEach(TextSize.allCases, id: \.self) { size in
                        Text(size.localizedName(for: selectedLanguage))
                            .tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedSize) {
                    textSizeManager.setTextSize(selectedSize)
                }
                
                HStack {
                    Button(action: {
                        selectedSize = .medium // ← ИСПРАВЛЕНО: обновляем локальное состояние
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
            .onAppear {
                selectedSize = textSizeManager.textSize // ← ИСПРАВЛЕНО: синхронизируем при появлении
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(t("Готово")) {
                        // закрытие панели
                    }
                }
            }
        }
    }
    
    private func getFontSize() -> CGFloat {
        let baseSize: CGFloat = 17
        return baseSize * textSizeManager.textSize.scale
    }
    
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}

// Расширение для локализации размеров текста
extension TextSize {
    func localizedName(for language: String) -> String {
        let names: [String: [TextSize: String]] = [
            "ru": [.small: "Мелкий", .medium: "Средний", .large: "Крупный"],
            "en": [.small: "Small", .medium: "Medium", .large: "Large"],
            "de": [.small: "Klein", .medium: "Mittel", .large: "Groß"],
            "tj": [.small: "Хурд", .medium: "Миёна", .large: "Калон"],
            "fa": [.small: "کوچک", .medium: "متوسط", .large: "بزرگ"],
            "ar": [.small: "صغير", .medium: "متوسط", .large: "كبير"],
            "uk": [.small: "Дрібний", .medium: "Середній", .large: "Великий"]
        ]
        return names[language]?[self] ?? "Medium"
    }
}
