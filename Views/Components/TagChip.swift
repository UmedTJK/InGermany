//
//  TagChip.swift
//  InGermany
//

import SwiftUI

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DS.Typography.chip)
            .foregroundStyle(DS.Color.textSecondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, DS.Spacing.s)
            .padding(.vertical, DS.Spacing.xs)
            .frame(minHeight: 28)
            .background(DS.Color.secondarySurface)
            .cornerRadius(DS.Radius.chip)
            .accessibilityLabel(Text(text))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: DS.Spacing.m) {
        TagChip(text: "Residence Permit")
        TagChip(text: "Integration Course")
        TagChip(text: "VeryLongTagExampleThatShouldTruncate")
    }
    .padding()
    .background(DS.Color.background)
}
#endif
