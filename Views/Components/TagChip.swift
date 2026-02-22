//
//  TagChip.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//

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
