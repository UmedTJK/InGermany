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
        ("tj", "Тоҷикӣ"),
        ("de", "Deutsch"),
        ("fa", "فارسی"),
        ("ar", "العربية"),
        ("uk", "Українська")
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
        case "fa":
            return minutes == 1 ? "1 دقیقه" : "\(minutes) دقیقه"
        case "ar":
            return minutes == 1 ? "دقيقة واحدة" : "\(minutes) دقائق"
        case "uk":
            return minutes == 1 ? "1 хвилина" : "\(minutes) хвилин"
        default: // "ru"
            return minutes == 1 ? "1 минута" : "\(minutes) минут"
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Язык приложения": ["ru": "Язык приложения", "en": "App Language", "de": "App-Sprache", "tj": "Забони барнома", "fa": "زبان برنامه", "ar": "لغة التطبيق", "uk": "Мова застосунку"],
            "Выберите язык": ["ru": "Выберите язык", "en": "Choose language", "de": "Sprache wählen", "tj": "Забонро интихоб кунед", "fa": "انتخاب زبان", "ar": "اختر اللغة", "uk": "Виберіть мову"],
            "Внешний вид": ["ru": "Внешний вид", "en": "Appearance", "de": "Erscheinungsbild", "tj": "Намуди зоҳирӣ", "fa": "ظاهر", "ar": "المظهر", "uk": "Зовнішній вигляд"],
            "Тёмная тема": ["ru": "Тёмная тема", "en": "Dark theme", "de": "Dunkles Theme", "tj": "Мавзӯи торик", "fa": "حالت تاریک", "ar": "الوضع الداكن", "uk": "Темна тема"],
            "Размер текста": ["ru": "Размер текста", "en": "Text Size", "de": "Textgröße", "tj": "Андозаи матн", "fa": "اندازه متن", "ar": "حجم النص", "uk": "Розмір тексту"],
            "Формат даты": ["ru": "Формат даты", "en": "Date format", "de": "Datumsformat", "tj": "Формати сана", "fa": "قالب تاریخ", "ar": "تنسيق التاريخ", "uk": "Формат дати"],
            "Относительные даты": ["ru": "Относительные даты", "en": "Relative dates", "de": "Relative Daten", "tj": "Санаҳои нисбӣ", "fa": "تاریخ نسبی", "ar": "تواريخ نسبية", "uk": "Відносні дати"],
            "Статистика чтения": ["ru": "Статистика чтения", "en": "Reading Statistics", "de": "Lese-Statistiken", "tj": "Омори хондан", "fa": "آمار مطالعه", "ar": "إحصاءات القراءة", "uk": "Статистика читання"],
            "Прочитано статей": ["ru": "Прочитано статей", "en": "Articles read", "de": "Gelesene Artikel", "tj": "Мақолаҳои хондашуда", "fa": "مقالات خوانده‌شده", "ar": "مقالات مقروءة", "uk": "Прочитані статті"],
            "Общее время чтения": ["ru": "Общее время чтения", "en": "Total reading time", "de": "Gesamte Lesezeit", "tj": "Вақти умумии хондан", "fa": "زمان کل مطالعه", "ar": "إجمالي وقت القراءة", "uk": "Загальний час читання"],
            "Среднее время на статью": ["ru": "Среднее время на статью", "en": "Average time per article", "de": "Durchschnittliche Zeit pro Artikel", "tj": "Вақти миёна барои мақола", "fa": "میانگین زمان برای هر مقاله", "ar": "متوسط الوقت لكل مقالة", "uk": "Середній час на статтю"],
            "Дней подряд читаете": ["ru": "Дней подряд читаете", "en": "Reading streak", "de": "Lese-Serie", "tj": "Рӯзҳои пайдарпайи хондан", "fa": "روزهای متوالی مطالعه", "ar": "أيام قراءة متتالية", "uk": "Днів підряд читаєте"],
            "Очистить историю чтения": ["ru": "Очистить историю чтения", "en": "Clear reading history", "de": "Lesehistorie löschen", "tj": "Таърихи хонданро пок кардан", "fa": "پاک کردن تاریخچه مطالعه", "ar": "مسح سجل القراءة", "uk": "Очистити історію читання"],
            "О приложении": ["ru": "О приложении", "en": "About App", "de": "Über die App", "tj": "Дар бораи барнома", "fa": "درباره برنامه", "ar": "عن التطبيق", "uk": "Про застосунок"],
            "Описание приложения": [
                "ru": "Справочник для мигрантов … Поддержка языков: Русский, English, Тоҷикӣ, Deutsch, فارسی, العربية, Українська.",
                "en": "A guide for migrants … Language support: Russian, English, Tajik, German, Persian, Arabic, Ukrainian.",
                "de": "Ein Leitfaden … Sprachunterstützung: Russisch, Englisch, Tadschikisch, Deutsch, Persisch, Arabisch, Ukrainisch.",
                "tj": "Роҳнамо … Дастгирии забонҳо: Русӣ, Англисӣ, Тоҷикӣ, Олмонӣ, Форсӣ, Арабӣ, Украинӣ.",
                "fa": "راهنما … پشتیبانی از زبان‌ها: روسی، انگلیسی، تاجیکی، آلمانی، فارسی، عربی، اوکراینی.",
                "ar": "دليل … دعم اللغات: الروسية، الإنجليزية، الطاجيكية، الألمانية، الفارسية، العربية، الأوكرانية.",
                "uk": "Довідник … Підтримка мов: Російська, Англійська, Таджицька, Німецька, Перська, Арабська, Українська."
            ],
            "Подробнее о проекте": ["ru": "Подробнее о проекте", "en": "More about project", "de": "Mehr über das Projekt", "tj": "Бештар дар бораи лоиҳа", "fa": "اطلاعات بیشتر درباره پروژه", "ar": "المزيد عن المشروع", "uk": "Докладніше про проєкт"],
            "Настройки": ["ru": "Настройки", "en": "Settings", "de": "Einstellungen", "tj": "Танзимот", "fa": "تنظیمات", "ar": "الإعدادات", "uk": "Налаштування"]
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
