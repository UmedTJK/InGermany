// ReadingProgressHelper.swift

import SwiftUI

struct ReadingProgressHelper {
    private let localizationManager: LocalizationManager

    init(localizationManager: LocalizationManager) {
        self.localizationManager = localizationManager
    }

    func color(for progress: CGFloat) -> Color {
        switch progress {
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }

    func status(for progress: CGFloat, language: String) -> String {
        switch progress {
        case 0..<0.1: return localizationManager.getTranslation(key: "Начало", language: language)
        case 0.1..<0.7: return localizationManager.getTranslation(key: "В процессе", language: language)
        case 0.7..<0.99: return localizationManager.getTranslation(key: "Почти готово", language: language)
        default: return localizationManager.getTranslation(key: "Готово", language: language)
        }
    }

    func progressView(progress: CGFloat, language: String) -> some View {
        HStack {
            ReadingProgressBar(
                progress: progress,
                height: 6,
                foregroundColor: color(for: progress),
                isReading: true
            )
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(status(for: progress, language: language))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.horizontal)
    }
}
