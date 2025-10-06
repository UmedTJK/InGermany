import SwiftUI

struct AboutView: View {
    @StateObject private var viewModel: AboutViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @EnvironmentObject private var appContainer: AppContainer

    /// Initializes the view with AppContainer for dependency injection
    init(appContainer: AppContainer) {
        _viewModel = StateObject(wrappedValue: appContainer.makeAboutViewModel())
    }
    
    /// For preview and testing
    init(viewModel: AboutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    Text("\(t("Версия")): \(viewModel.appVersion)")
                    Text("\(t("Сборка")): \(viewModel.buildNumber)")
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
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    AboutView(appContainer: AppContainer.shared)
        .environmentObject(AppContainer.shared)
}
