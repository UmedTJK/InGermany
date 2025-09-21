//
//  UsefulToolsSection.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

import SwiftUI

struct UsefulToolsSection: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.translate("UsefulTools")) // УБРАЛИ language
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ToolCard(
                        title: LocalizationManager.shared.translate("Map"), // УБРАЛИ language
                        systemImage: "map.fill",
                        color: .blue
                    )
                    ToolCard(
                        title: LocalizationManager.shared.translate("PDFDocuments"), // УБРАЛИ language
                        systemImage: "doc.richtext",
                        color: .green
                    )
                    ToolCard(
                        title: LocalizationManager.shared.translate("RandomArticle"), // УБРАЛИ language
                        systemImage: "shuffle",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
