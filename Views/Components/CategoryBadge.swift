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
        guard let rgb = parseRGB(from: hex) else { return .white }

        func toLinear(_ c: CGFloat) -> CGFloat {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        let r = toLinear(rgb.r)
        let g = toLinear(rgb.g)
        let b = toLinear(rgb.b)
        let rl = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return rl > 0.55 ? .black : .white
    }

    private static func parseRGB(from hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.hasPrefix("#") { string.removeFirst() }
        guard let value = UInt64(string, radix: 16) else { return nil }

        let r, g, b: UInt64
        switch string.count {
        case 6:
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        case 8:
            // ARGB
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
        default:
            return nil
        }

        return (
            r: CGFloat(r) / 255,
            g: CGFloat(g) / 255,
            b: CGFloat(b) / 255
        )
    }
}

#if DEBUG
#Preview {
    VStack(spacing: DS.Spacing.m) {
        CategoryBadge(title: "Light BG", systemImage: "tag.fill", backgroundHex: "#E6F0FF")
        CategoryBadge(title: "Dark BG", systemImage: "tag.fill", backgroundHex: "#1B3A57")
    }
    .padding()
    .background(DS.Color.background)
}
#endif
