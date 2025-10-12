import SwiftUI

/// Custom floating tab bar with animation and modern iOS look
struct CustomTabBarView: View {
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    
    // MARK: - Dependencies
    let appContainer: AppContainer

    var body: some View {
        VStack(spacing: 0) {
            // Контент текущей вкладки
            Group {
                switch selectedTab {
                case 0:
                    HomeView(appContainer: appContainer)
                case 1:
                    CategoriesView(appContainer: appContainer)
                case 2:
                    SearchView(viewModel: appContainer.makeSearchViewModel())
                case 3:
                    FavoritesView(viewModel: appContainer.makeFavoritesViewModel())
                case 4:
                    SettingsView(viewModel: appContainer.makeSettingsViewModel())
                default:
                    HomeView(appContainer: appContainer)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 👇 кастомный TabBar
            HStack {
                tabButton(icon: "house.fill", index: 0)
                Spacer()
                tabButton(icon: "square.grid.2x2", index: 1)
                Spacer()
                tabButton(icon: "magnifyingglass", index: 2)
                Spacer()
                tabButton(icon: "star.fill", index: 3)
                Spacer()
                tabButton(icon: "gearshape.fill", index: 4)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder
    private func tabButton(icon: String, index: Int) -> some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                if selectedTab == index {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .matchedGeometryEffect(id: "indicator", in: animation)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(selectedTab == index ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
