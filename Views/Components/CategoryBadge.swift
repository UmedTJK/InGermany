//
//  CategoryBadge.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//
//
//  CategoryBadge.swift
//  InGermany
//

import SwiftUI

struct CategoryBadge: View {
    let title: String
    let systemImage: String
    let backgroundHex: String

    var body: some View {
        let bg = Color(hex: backgroundHex) ?? DS.Color.surface
        let fg: Color = Self.contrastForeground(for: backgroundHex)

        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: systemImage)
                .font(DS.Typography.meta)
            Text(title)
                .font(DS.Typography.badge)
        }
        .padding(DS.Spacing.s)
        .background(bg.opacity(0.85))
        .foregroundStyle(fg)
        .cornerRadius(DS.Radius.badge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
    }

    private static func contrastForeground(for hex: String) -> Color {
        guard let uiColor = UIColor(hex: hex) else { return .white }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        func toLinear(_ c: CGFloat) -> CGFloat {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let rl = 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b)
        return rl > 0.55 ? .black : .white
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }

        guard let value = UInt64(string, radix: 16) else { return nil }

        let a, r, g, b: UInt64
        switch string.count {
        case 6:
            a = 255
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        case 8:
            a = (value >> 24) & 0xFF
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        default:
            return nil
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
