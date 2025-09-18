//
//  ReadingProgressBar.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import SwiftUI

struct ReadingProgressBar: View {
    let progress: CGFloat // От 0.0 до 1.0
    let height: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: CGFloat,
        height: CGFloat = 4,
        cornerRadius: CGFloat = 2,
        backgroundColor: Color = Color.gray.opacity(0.2),
        foregroundColor: Color = Color.blue
    ) {
        self.progress = max(0, min(1, progress)) // Ограничиваем от 0 до 1
        self.height = height
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Фон прогресс-бара
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: height)
                    .cornerRadius(cornerRadius)
                
                // Заполненная часть
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [foregroundColor, foregroundColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
                    .cornerRadius(cornerRadius)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Reading Progress Tracker

class ReadingProgressTracker: ObservableObject {
    @Published var scrollProgress: CGFloat = 0
    @Published var isReading: Bool = false
    
    private var contentHeight: CGFloat = 0
    private var visibleHeight: CGFloat = 0
    
    func updateProgress(contentOffset: CGPoint, contentSize: CGSize, visibleSize: CGSize) {
        contentHeight = contentSize.height
        visibleHeight = visibleSize.height
        
        // Рассчитываем прогресс чтения
        let maxOffset = max(0, contentHeight - visibleHeight)
        
        if maxOffset > 0 {
            scrollProgress = max(0, min(1, contentOffset.y / maxOffset))
        } else {
            scrollProgress = 1 // Весь контент виден
        }
        
        // Считаем, что пользователь читает, если прогресс больше 5%
        isReading = scrollProgress > 0.05
    }
    
    func reset() {
        scrollProgress = 0
        isReading = false
    }
}

// MARK: - Scroll Tracking View Modifier

struct ScrollTrackingModifier: ViewModifier {
    @ObservedObject var progressTracker: ReadingProgressTracker
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scrollView")).origin
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Обновляем прогресс (упрощенная версия)
                let progress = max(0, min(1, -value.y / 500)) // 500 - примерная высота контента
                progressTracker.scrollProgress = progress
                progressTracker.isReading = progress > 0.05
            }
    }
}

// MARK: - Preference Key для отслеживания скролла

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - View Extension

extension View {
    func trackReadingProgress(_ progressTracker: ReadingProgressTracker) -> some View {
        modifier(ScrollTrackingModifier(progressTracker: progressTracker))
    }
}

// MARK: - Reading Progress View (для использования в ArticleView)

struct ReadingProgressView: View {
    @ObservedObject var progressTracker: ReadingProgressTracker
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(getTranslation(key: "Прогресс чтения", language: selectedLanguage))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progressTracker.scrollProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            ReadingProgressBar(
                progress: progressTracker.scrollProgress,
                height: 6,
                foregroundColor: progressTracker.isReading ? .green : .blue
            )
            
            // Дополнительная информация
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if progressTracker.isReading {
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text(getTranslation(key: "Читаете", language: selectedLanguage))
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Прогресс чтения": [
                "ru": "Прогресс чтения",
                "en": "Reading Progress",
                "de": "Lesefortschritt",
                "tj": "Пешравии хондан"
            ],
            "Читаете": [
                "ru": "Читаете",
                "en": "Reading",
                "de": "Lesen",
                "tj": "Хонед"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

// MARK: - Circular Progress (альтернативный стиль)

struct CircularReadingProgress: View {
    let progress: CGFloat
    let size: CGFloat
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: CGFloat,
        size: CGFloat = 40,
        lineWidth: CGFloat = 4,
        backgroundColor: Color = Color.gray.opacity(0.2),
        foregroundColor: Color = Color.blue
    ) {
        self.progress = max(0, min(1, progress))
        self.size = size
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            // Фон круга
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            // Прогресс
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Текст с процентами (опционально)
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .medium))
                .foregroundColor(foregroundColor)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        ReadingProgressBar(progress: 0.3)
        
        ReadingProgressBar(
            progress: 0.7,
            height: 8,
            foregroundColor: .green
        )
        
        CircularReadingProgress(progress: 0.65)
        
        CircularReadingProgress(
            progress: 0.9,
            size: 60,
            foregroundColor: .orange
        )
    }
    .padding()
}
