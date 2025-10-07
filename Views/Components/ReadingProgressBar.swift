//
//  ReadingProgressBar.swift
//  InGermany
//

import SwiftUI

/// Прогресс-бар чтения статьи, показывающий процент прочитанного и статус активности.
struct ReadingProgressBar: View {
    /// Текущее значение прогресса чтения (0.0–1.0).
    var progress: CGFloat
    /// Высота индикатора прогресса.
    var height: CGFloat
    /// Цвет заполненной части прогресса.
    var foregroundColor: Color
    /// Флаг, показывающий, читается ли статья в данный момент.
    var isReading: Bool = false

    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Основное содержимое: прогресс-бар и подписи о состоянии чтения.
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

    /// Шорткат для перевода текста через LocalizationManager.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }

    /// Старый метод перевода, оставлен для совместимости.
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
