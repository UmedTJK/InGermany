//
//  ArticleBlockView.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

/// Универсальный блок для оформления статей (Info, Warning, Tip, Quote)
public struct ArticleBlockView: View {
    public enum BlockStyle {
        case info, warning, tip, quote
    }

    public let text: String
    public let style: BlockStyle

    public init(text: String, style: BlockStyle) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            icon
                .font(.system(size: 20))
                .frame(width: 24, height: 24)
                .padding(.top, 2)

            Text(text)
                .font(style == .quote ? .italic(.body)() : .body)
                .multilineTextAlignment(.leading)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        .padding(.vertical, 4)
    }

    // MARK: - Styles
    private var icon: Text {
        switch style {
        case .info: return Text("📘")
        case .warning: return Text("⚠️")
        case .tip: return Text("💡")
        case .quote: return Text("❝")
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .info: return Color.blue.opacity(0.1)
        case .warning: return Color.red.opacity(0.1)
        case .tip: return Color.green.opacity(0.1)
        case .quote: return Color.gray.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch style {
        case .info: return Color.blue.opacity(0.3)
        case .warning: return Color.red.opacity(0.3)
        case .tip: return Color.green.opacity(0.3)
        case .quote: return Color.gray.opacity(0.3)
        }
    }

    private var textColor: Color {
        switch style {
        case .info: return Color.primary
        case .warning: return Color.red
        case .tip: return Color.green.darker()
        case .quote: return Color.primary.opacity(0.8)
        }
    }
}

public extension Color {
    /// Утилита для затемнения цветов
    func darker(by percentage: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: max(r - percentage, 0),
                     green: max(g - percentage, 0),
                     blue: max(b - percentage, 0))
    }
}
