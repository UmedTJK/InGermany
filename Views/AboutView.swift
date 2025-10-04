//
//  AboutView.swift
//  InGermany
//

import SwiftUI

/// Экран 'О приложении'. Отображает информацию о версии, сборке и ссылку на репозиторий проекта.
struct AboutView: View {
    @StateObject private var viewModel: AboutViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    init() {
        _viewModel = StateObject(wrappedValue: AppContainer.shared.makeAboutViewModel())
    }

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

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(t("version")): \(viewModel.appVersion)")
                    Text("\(t("build")): \(viewModel.buildNumber)")
                    Link(viewModel.repositoryURL, destination: URL(string: viewModel.repositoryURL)!)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle(t("tab_about"))
    }

    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }
}
