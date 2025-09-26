//
//  ReadingProgressBar.swift
//  InGermany
//

import SwiftUI

struct ReadingProgressBar: View {
    var progress: CGFloat
    var height: CGFloat
    var foregroundColor: Color
    var isReading: Bool = false

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: height)

                    Rectangle()
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * progress, height: height)
                }
            }
            .frame(height: height)

            HStack {
                Text(t("Прогресс чтения"))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if isReading {
                    Text(t("Читаете"))
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // 🔹 Шорткат для нового менеджера
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }

    // 🔹 Старый метод (оставлен для совместимости)
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Прогресс чтения": [
                "ru": "Прогресс чтения", "en": "Reading progress", "de": "Lesefortschritt",
                "tj": "Пешрафти хондан", "fa": "پیشرفت مطالعه", "ar": "تقدم القراءة", "uk": "Прогрес читання"
            ],
            "Читаете": [
                "ru": "Читаете", "en": "Reading", "de": "Am Lesen",
                "tj": "Дар ҳолати хондан", "fa": "در حال مطالعه", "ar": "تقرأ", "uk": "Читаєте"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
