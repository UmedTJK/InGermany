//
//  TextSizeSettingsPanel.swift
//  InGermany
//
//  Created by Umed Sabzaev on 20.09.25.
//

import SwiftUI

struct TextSizeSettingsPanel: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var textSizeManager = TextSizeManager.shared
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    private func localizedText(_ key: String) -> String {
        let translations: [String: [String: String]] = [
            "Размер текста": [
                "ru": "Размер текста", "en": "Text Size", "de": "Textgröße", "tj": "Андозаи матн",
                "fa": "اندازه متن", "ar": "حجم النص", "uk": "Розмір тексту"
            ],
            "Настройки текста": [
                "ru": "Настройки текста", "en": "Text Settings", "de": "Texteinstellungen", "tj": "Танзимоти матн",
                "fa": "تنظیمات متن", "ar": "إعدادات النص", "uk": "Налаштування тексту"
            ],
            "Сбросить": [
                "ru": "Сбросить", "en": "Reset", "de": "Zurücksetzen", "tj": "Бекор кардан",
                "fa": "بازنشانی", "ar": "إعادة تعيين", "uk": "Скинути"
            ],
            "Пример текста": [
                "ru": "Пример текста для предпросмотра размера шрифта",
                "en": "Sample text for font size preview",
                "de": "Beispieltext zur Vorschau der Schriftgröße",
                "tj": "Матни намуна барои дида барои андозаи ҳарф",
                "fa": "متن نمونه برای پیش‌نمایش اندازه فونت",
                "ar": "نص تجريبي لمعاينة حجم الخط",
                "uk": "Приклад тексту для перегляду розміру шрифту"
            ],
            "Пользовательский размер": [
                "ru": "Пользовательский размер", "en": "Custom Size", "de": "Benutzerdefinierte Größe", "tj": "Андозаи фардӣ",
                "fa": "اندازه سفارشی", "ar": "حجم مخصص", "uk": "Користувацький розмір"
            ],
            "Готово": [
                "ru": "Готово", "en": "Done", "de": "Fertig", "tj": "Омода",
                "fa": "انجام شد", "ar": "تم", "uk": "Готово"
            ]
        ]
        return translations[key]?[selectedLanguage] ?? key
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle(localizedText("Пользовательский размер"),
                          isOn: $textSizeManager.isCustomTextSizeEnabled)
                    
                    if textSizeManager.isCustomTextSizeEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(Int(textSizeManager.fontSize)) pt")
                                .font(.headline)
                            
                            Slider(
                                value: $textSizeManager.fontSize,
                                in: 12...30,
                                step: 1
                            )
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(textSizeManager.presetSizes, id: \.self) { size in
                                        Button {
                                            textSizeManager.fontSize = size
                                            HapticFeedback.light()
                                        } label: {
                                            Text("\(Int(size))")
                                                .font(.system(size: 14))
                                                .padding(8)
                                                .frame(minWidth: 40)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(textSizeManager.fontSize == size ?
                                                            Color.blue : Color.gray.opacity(0.2))
                                                )
                                                .foregroundColor(textSizeManager.fontSize == size ?
                                                    .white : .primary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                Section {
                    Text(localizedText("Пример текста"))
                        .font(textSizeManager.isCustomTextSizeEnabled ?
                              textSizeManager.currentFont : .body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                Section {
                    Button(localizedText("Сбросить")) {
                        textSizeManager.resetToDefault()
                        HapticFeedback.medium()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(localizedText("Настройки текста"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localizedText("Готово")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
