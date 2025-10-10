//
//  TagsView.swift
//  InGermany
//
//  Created by SUM TJK on 09.10.25.
//
//
//  TagsView.swift
//  InGermany
//
//  Created by ChatGPT on 09.10.25.
//

import SwiftUI

/// Displays a horizontal list of non-interactive tags with translation support.
struct TagsView: View {
    let tags: [String]
    let language: String
    let localizationManager: LocalizationManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text("#" + t(tag))
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func t(_ key: String) -> String {
        localizationManager.getTranslation(key: key, language: language)
    }
}

