//
//  SettingsView.swift
//  InGermany
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("useRelativeDates") private var useRelativeDates: Bool = true
    
    @ObservedObject private var readingHistoryManager = ReadingHistoryManager.shared
    @StateObject private var textSizeManager = TextSizeManager.shared
    
    // Поддерживаемые языки
    private let languages = [
        ("ru", "Русский"),
        ("en", "English"),
        ("tj", "Тоҷикӣ")
    ]
    
    private var readingStats: ReadingStats {
        ReadingStats(from: readingHistoryManager.history)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Язык приложения
                Section(header: Text(getTranslation(key: "Язык приложения", language: selectedLanguage))) {
                    Picker(getTranslation(key: "Выберите язык", language: selectedLanguage), selection: $selectedLanguage) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Внешний вид
                Section(header: Text(getTranslation(key: "Внешний вид", language: selectedLanguage))) {
                    Toggle(isOn: $isDarkMode) {
                        Label(getTranslation(key: "Тёмная тема", language: selectedLanguage), systemImage: "moon.fill")
                    }
                    
                    NavigationLink {
                        TextSizeSettingsPanel()
                    } label: {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.blue)
                            Text(getTranslation(key: "Размер текста", language: selectedLanguage))
                            Spacer()
                            if textSizeManager.isCustomTextSizeEnabled {
                                Text("\(Int(textSizeManager.fontSize)) pt")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Формат даты
                Section(header: Text(getTranslation(key: "Формат даты", language: selectedLanguage))) {
                    Toggle(isOn: $useRelativeDates) {
                        Label(getTranslation(key: "Относительные даты", language: selectedLanguage),
                              systemImage: "calendar")
                    }
                }
                
                // Статистика чтения
                if readingStats.totalArticlesRead > 0 {
                    Section(header: Text(getTranslation(key: "Статистика чтения", language: selectedLanguage))) {
                        VStack(alignment: .leading, spacing: 12) {
                            StatRow(
                                icon: "book.fill",
                                label: getTranslation(key: "Прочитано статей", language: selectedLanguage),
                                value: "\(readingStats.totalArticlesRead)"
                            )
                            
                            StatRow(
                                icon: "clock.fill",
                                label: getTranslation(key: "Общее время чтения", language: selectedLanguage),
                                value: formatReadingTime(readingStats.totalReadingTimeMinutes, language: selectedLanguage)
                            )
                            
                            StatRow(
                                icon: "chart.line.uptrend.xyaxis",
                                label: getTranslation(key: "Среднее время на статью", language: selectedLanguage),
                                value: formatReadingTime(Int(readingStats.averageReadingTimeMinutes), language: selectedLanguage)
                            )
                            
                            if readingStats.readingStreak > 0 {
                                StatRow(
                                    icon: "flame.fill",
                                    label: getTranslation(key: "Дней подряд читаете", language: selectedLanguage),
                                    value: "\(readingStats.readingStreak)"
                                )
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Кнопка очистки истории
                        Button(action: {
                            readingHistoryManager.clearHistory()
                        }) {
                            Label(getTranslation(key: "Очистить историю чтения", language: selectedLanguage), systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // О приложении
                Section(header: Text(getTranslation(key: "О приложении", language: selectedLanguage))) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("InGermany – Work, Life and Study")
                            .font(.headline)
                        Text(getTranslation(key: "Описание приложения", language: selectedLanguage))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    NavigationLink(destination: AboutView()) {
                        Label(getTranslation(key: "Подробнее о проекте", language: selectedLanguage), systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle(getTranslation(key: "Настройки", language: selectedLanguage))
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatReadingTime(_ minutes: Int, language: String) -> String {
        switch language {
        case "en":
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        case "de":
            return minutes == 1 ? "1 Minute" : "\(minutes) Minuten"
        case "tj":
            return minutes == 1 ? "1 дақиқа" : "\(minutes) дақиқа"
        default: // "ru"
            return minutes == 1 ? "1 минута" : "\(minutes) минут"
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Язык приложения": ["ru": "Язык приложения", "en": "App Language", "de": "App-Sprache", "tj": "Забони барнома"],
            "Выберите язык": ["ru": "Выберите язык", "en": "Choose language", "de": "Sprache wählen", "tj": "Забонро интихоб кунед"],
            "Внешний вид": ["ru": "Внешний вид", "en": "Appearance", "de": "Erscheinungsbild", "tj": "Намуди зоҳирӣ"],
            "Тёмная тема": ["ru": "Тёмная тема", "en": "Dark theme", "de": "Dunkles Theme", "tj": "Мавзӯи торик"],
            "Размер текста": ["ru": "Размер текста", "en": "Text Size", "de": "Textgröße", "tj": "Андозаи матн"],
            "Формат даты": ["ru": "Формат даты", "en": "Date format", "de": "Datumsformat", "tj": "Формати сана"],
            "Относительные даты": ["ru": "Относительные даты", "en": "Relative dates", "de": "Relative Daten", "tj": "Санаҳои нисбӣ"],
            "Статистика чтения": ["ru": "Статистика чтения", "en": "Reading Statistics", "de": "Lese-Statistiken", "tj": "Омори хондан"],
            "Прочитано статей": ["ru": "Прочитано статей", "en": "Articles read", "de": "Gelesene Artikel", "tj": "Мақолаҳои хондашуда"],
            "Общее время чтения": ["ru": "Общее время чтения", "en": "Total reading time", "de": "Gesamte Lesezeit", "tj": "Вақти умумии хондан"],
            "Среднее время на статью": ["ru": "Среднее время на статью", "en": "Average time per article", "de": "Durchschnittliche Zeit pro Artikel", "tj": "Вақти миёна барои мақола"],
            "Дней подряд читаете": ["ru": "Дней подряд читаете", "en": "Reading streak", "de": "Lese-Serie", "tj": "Рӯзҳои пайдарпайи хондан"],
            "Очистить историю чтения": ["ru": "Очистить историю чтения", "en": "Clear reading history", "de": "Lesehistorie löschen", "tj": "Таърихи хонданро пок кардан"],
            "О приложении": ["ru": "О приложении", "en": "About App", "de": "Über die App", "tj": "Дар бораи барнома"],
            "Описание приложения": [
                "ru": "Справочник для мигрантов и тех, кто планирует переезд в Германию. Содержит статьи о работе, учёбе, бюрократии и финансах. Поддержка языков: Русский, English, Тоҷикӣ.",
                "en": "A guide for migrants and those planning to move to Germany. Contains articles about work, study, bureaucracy and finance. Language support: Russian, English, Tajik.",
                "de": "Ein Leitfaden für Migranten und alle, die nach Deutschland ziehen möchten. Enthält Artikel über Arbeit, Studium, Bürokratie und Finanzen. Sprachunterstützung: Russisch, Englisch, Tadschikisch.",
                "tj": "Роҳнамо барои муҳоҷирон ва онҳое, ки ба Олмон кӯчидан мехоҳанд. Дорои мақолаҳо дар бораи кор, таҳсил, бюрократия ва молия. Дастгирии забонҳо: Русӣ, Англисӣ, Тоҷикӣ."
            ],
            "Подробнее о проекте": ["ru": "Подробнее о проекте", "en": "More about project", "de": "Mehr über das Projekt", "tj": "Бештар дар бораи лоиҳа"],
            "Настройки": ["ru": "Настройки", "en": "Settings", "de": "Einstellungen", "tj": "Танзимот"]
        ]
        return translations[key]?[language] ?? key
    }
}

// MARK: - Статистика чтения - компонент строки
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(.primary)
        }
    }
}
