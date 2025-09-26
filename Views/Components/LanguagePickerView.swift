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
        Section(header: Text(NSLocalizedString("settings_language_title", comment: ""))) {
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
        if let lang = languages.first(where: { $0.code == code }) {
            return "\(lang.flag) \(lang.name)"
        }
        return code
    }
}
