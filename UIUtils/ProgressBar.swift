//  ProgressBar.swift
//  InGermany

import SwiftUI

/// Многоразовый компонент прогресс-бара для отображения прогресса чтения или загрузки.
struct ProgressBar: View {
    /// Текущее значение прогресса от 0.0 до 1.0
    var value: CGFloat

    /// Строит визуальное представление прогресс-бара с серым фоном и синим индикатором
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 4)
                    .opacity(0.3)
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: geometry.size.width * value, height: 4)
                    .foregroundColor(.blue)
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: 4)
    }
}
