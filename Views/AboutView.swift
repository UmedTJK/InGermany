//
//  AboutView.swift
//  InGermany
//

import SwiftUI

struct AboutView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("InGermany")
                    .font(.largeTitle)
                    .bold()

                Text(t("about_description"))
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(t("tab_about"))
    }

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
