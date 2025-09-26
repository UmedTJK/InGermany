//
//  LanguagePickerView.swift
//  InGermany
//

import SwiftUI

struct LanguagePickerView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    private let languages: [(code: String, name: String, flag: String)] = [
        ("ru", "Русский", "🇷🇺"),
        ("en", "English", "🇬🇧"),
        ("de", "Deutsch", "🇩🇪"),
        ("tj", "Тоҷикӣ", "🇹🇯"),
        ("fa", "فارسی", "🇮🇷"),
        ("ar", "العربية", "🇸🇦"),
        ("uk", "Українська", "🇺🇦")
    ]

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

    private func labelFor(code: String) -> String {
        languages.first { $0.code == code }?.name ?? code
    }
}
