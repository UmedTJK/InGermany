import SwiftUI

struct AboutView: View {

    @StateObject private var viewModel: AboutViewModel

    /// Dependency-injected initializer (composition root / previews)
    init(viewModel: AboutViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("app.name")
                    .font(.largeTitle)
                    .bold()

                Text("about.description")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("about.build.label \(viewModel.buildNumber)")

                    Link(viewModel.repositoryURL, destination: URL(string: viewModel.repositoryURL)!)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("tab.about")
    }

}

// MARK: - Preview
#Preview {
    let container = AppContainer.previewMock()
    AboutView(viewModel: container.makeAboutViewModel())
        .appEnvironment(using: container)
}
