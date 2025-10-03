//
//  ReadingProgressHelper.swift
//  InGermany
//
//  Created by SUM TJK on 26.09.25.
//

//
//  ReadingProgressHelper.swift
//  InGermany
//

import SwiftUI

struct ReadingProgressHelper {
    
    /// Определяет цвет прогресс-бара по проценту
    static func color(for progress: CGFloat) -> Color {
        switch progress {
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
    
    /// Возвращает локализованный статус по проценту
    static func status(for progress: CGFloat, language: String) -> String {
        let lm = LocalizationManager.shared
        switch progress {
        case 0..<0.1: return lm.getTranslation(key: "Начало", language: language)
        case 0.1..<0.7: return lm.getTranslation(key: "В процессе", language: language)
        case 0.7..<0.99: return lm.getTranslation(key: "Почти готово", language: language)
        default: return lm.getTranslation(key: "Готово", language: language)
        }
    }
    
    /// Строит блок отображения прогресса (бар + проценты + статус)
    static func progressView(progress: CGFloat, language: String) -> some View {
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
