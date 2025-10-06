//
//  LanguagePickerView.swift
//  InGermany
//

import SwiftUI

/// Компонент выбора языка интерфейса приложения.
struct LanguagePickerView: View {
    /// Код выбранного языка, сохраняемый в AppStorage.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Список доступных языков с кодом, локализованным названием и эмодзи-флагом.
    private let languages: [(code: String, name: String, flag: String)] = [
        ("ru", "Русский", "🇷🇺"),
        ("en", "English", "🇬🇧"),
        ("de", "Deutsch", "🇩🇪"),
        ("tj", "Тоҷикӣ", "🇹🇯"),
        ("fa", "فارسی", "🇮🇷"),
        ("ar", "العربية", "🇸🇦"),
        ("uk", "Українська", "🇺🇦")
    ]

    /// Секция с выпадающим списком (Picker) для выбора языка интерфейса.
    var body: some View {
        Section {
            Picker(selection: $selectedLanguage,
                   label: Text(labelFor(code: selectedLanguage))) {
                ForEach(languages, id: \.code) { lang in
                    Text("\(lang.flag) \(lang.name)").tag(lang.code)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    /// Возвращает локализованное название языка по его коду.
    private func labelFor(code: String) -> String {
        languages.first { $0.code == code }?.name ?? code
    }
}
