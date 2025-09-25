//
//  AboutView.swift
//  InGermany
//

import SwiftUI

struct AboutView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("InGermany")
                    .font(.largeTitle)
                    .bold()
                
                Text(getTranslation(key: "Описание", language: selectedLanguage))
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(getTranslation(key: "О приложении", language: selectedLanguage))
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "О приложении": [
                "ru": "О приложении",
                "en": "About",
                "de": "Über",
                "tj": "Дар бораи барнома",
                "fa": "درباره",
                "ar": "عن التطبيق",
                "uk": "Про застосунок"
            ],
            "Описание": [
                "ru": """
InGermany — справочник для мигрантов о жизни, учёбе и работе в Германии. 
Приложение создаётся как showcase-проект для портфолио iOS-разработчика.

🔹 Основные особенности:
• Поддержка 7 языков: Русский, English, Тоҷикӣ, Deutsch, فارسی, العربية, Українська  
• Офлайн-режим с обновлением данных через GitHub Pages  
• Поддержка тёмной/светлой темы, избранного, поиска, тегов  
• Экспорт статей в PDF, встроенный просмотр карт, история чтения  

🎯 Цель проекта — продемонстрировать современные практики SwiftUI (iOS 17+), 
чистую модульную архитектуру (Core / Views / Models / Services / Utils) 
и гибкую работу с мультиязычными данными.
""",
                "en": """
InGermany — a guide for migrants about life, study, and work in Germany. 
The app is built as a showcase project for an iOS developer portfolio.

🔹 Key features:
• Supports 7 languages: Russian, English, Tajik, German, Persian, Arabic, Ukrainian  
• Offline-first with data updates via GitHub Pages  
• Dark/light theme, favorites, search, tags  
• Export articles to PDF, integrated maps, reading history  

🎯 The goal is to demonstrate modern SwiftUI practices (iOS 17+), 
a clean modular architecture (Core / Views / Models / Services / Utils), 
and flexible handling of multilingual data.
""",
                "de": """
InGermany — ein Leitfaden für Migranten über Leben, Studium und Arbeit in Deutschland. 
Die App unterstützt 7 Sprachen: Russisch, Englisch, Tadschikisch, Deutsch, Persisch, Arabisch, Ukrainisch.
""",
                "tj": """
InGermany — роҳнамо барои муҳоҷирон дар бораи зиндагӣ, таҳсил ва кор дар Олмон. 
Барнома 7 забонро дастгирӣ мекунад: Русӣ, Англисӣ, Тоҷикӣ, Олмонӣ, Форсӣ, Арабӣ, Украинӣ.
""",
                "fa": """
InGermany — راهنمای مهاجران درباره زندگی، تحصیل و کار در آلمان. 
برنامه از ۷ زبان پشتیبانی می‌کند: روسی، انگلیسی، تاجیکی، آلمانی، فارسی، عربی، اوکراینی.
""",
                "ar": """
InGermany — دليل للمهاجرين عن الحياة والدراسة والعمل في ألمانيا. 
يدعم التطبيق ٧ لغات: الروسية، الإنجليزية، الطاجيكية، الألمانية، الفارسية، العربية، الأوكرانية.
""",
                "uk": """
InGermany — довідник для мігрантів про життя, навчання та роботу в Німеччині. 
Додаток підтримує 7 мов: Російська, Англійська, Таджицька, Німецька, Перська, Арабська, Українська.
"""
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
