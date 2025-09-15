//
//  SettingsView.swift
//  InGermany

//  Created by SUM TJK on 13.09.25.
//

/// Экран настроек приложения InGermany
import SwiftUI

///
//  SettingsView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false   // новый флаг темы
    
    // Поддерживаемые языки
    private let languages = [
        ("ru", "Русский"),
        ("en", "English"),
        ("tj", "Тоҷикӣ")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Язык приложения
                Section(header: Text("Язык приложения")) {
                    Picker("Выберите язык", selection: $selectedLanguage) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Тема оформления
                Section(header: Text("Оформление")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Тёмная тема", systemImage: "moon.fill")
                    }
                }
                
                // О приложении
                Section(header: Text("О приложении")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("InGermany – Work, Life and Study")
                            .font(.headline)
                        Text("Справочник для мигрантов и тех, кто планирует переезд в Германию. Содержит статьи о работе, учёбе, бюрократии и финансах. Поддержка языков: Русский, English, Тоҷикӣ.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    
                    // 🔹 Навигационная кнопка на экран "О проекте"
                    NavigationLink(destination: AboutView()) {
                        Label("Подробнее о проекте", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
