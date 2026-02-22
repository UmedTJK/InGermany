//
//  SectionHeader.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DS.Typography.sectionTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer(minLength: DS.Spacing.s)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, DS.Spacing.contentInset)
        .padding(.top, DS.Spacing.xs)
    }
}
